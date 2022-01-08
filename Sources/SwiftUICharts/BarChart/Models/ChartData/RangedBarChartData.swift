//
//  RangedBarChartData.swift
//  
//
//  Created by Will Dale on 03/03/2021.
//

import SwiftUI
import Combine
import ChartMath

/**
 Data for drawing and styling a ranged Bar Chart.
 */
@available(macOS 11.0, iOS 14, watchOS 7, tvOS 14, *)
public final class RangedBarChartData: BarChartType, CTChartData, CTBarChartDataProtocol, StandardChartConformance, ChartAxes, ViewDataProtocol {
    // MARK: Properties
    public let id: UUID = UUID()
    @Published public var dataSets: RangedBarDataSet
    @Published public var barStyle: BarStyle
    @Published public var legends: [LegendData] = []
    @Published public var infoView = InfoViewData<RangedBarDataPoint>()
    @Published public var shouldAnimate: Bool
    public var noDataText: Text
    public var accessibilityTitle: LocalizedStringKey = ""
        
    // MARK: ViewDataProtocol
    @Published public var xAxisViewData = XAxisViewData()
    @Published public var yAxisViewData = YAxisViewData()
    
    // MARK: ChartAxes
    @Published public var xAxisLabels: [String]?
    @Published public var yAxisLabels: [String]?
    
    // MARK: Publishable
    @Published public var touchPointData: [DataPoint] = []
    public let touchedDataPointPublisher = PassthroughSubject<[PublishedTouchData<DataPoint>], Never>()
    
    // MARK: Touchable
    public var touchMarkerType: BarMarkerType = defualtTouchMarker
    
    // MARK: DataHelper
    public var baseline: Baseline
    public var topLine: Topline
    
    // MARK: ExtraLineDataProtocol
    @Published public var extraLineData: ExtraLineData!
    
    // MARK: Non-Protocol
    @Published public var chartSize: CGRect = .zero
    private var internalSubscription: AnyCancellable?
    private var markerData: MarkerData = MarkerData()
    private var internalDataSubscription: AnyCancellable?
    internal let chartType: CTChartType = (.bar, .single)
    
    // MARK: Deprecated
    @available(*, deprecated, message: "Please set the data in \".titleBox\" instead.")
    @Published public var metadata = ChartMetadata()
    @available(*, deprecated, message: "")
    @Published public var chartStyle = BarChartStyle()
    
    // MARK: Initializer
    /// Initialises a Ranged Bar Chart.
    ///
    /// - Parameters:
    ///   - dataSets: Data to draw and style the bars.
    ///   - xAxisLabels: Labels for the X axis instead of the labels in the data points.
    ///   - yAxisLabels: Labels for the Y axis instead of the labels generated from data point values.   
    ///   - barStyle: Control for the aesthetic of the bar chart.
    ///   - shouldAnimate: Whether the chart should be animated.
    ///   - noDataText: Customisable Text to display when where is not enough data to draw the chart.
    public init(
        dataSets: RangedBarDataSet,
        xAxisLabels: [String]? = nil,
        yAxisLabels: [String]? = nil,
        barStyle: BarStyle = BarStyle(),
        shouldAnimate: Bool = true,
        noDataText: Text = Text("No Data"),
        baseline: Baseline = .minimumValue,
        topLine: Topline = .maximumValue
    ) {
        self.dataSets = dataSets
        self.xAxisLabels = xAxisLabels
        self.yAxisLabels = yAxisLabels
        self.barStyle = barStyle
        self.shouldAnimate = shouldAnimate
        self.noDataText = noDataText
        self.baseline = baseline
        self.topLine = topLine
        
//        self.setupLegends()
        self.setupInternalCombine()
    }
    
    private func setupInternalCombine() {
        internalSubscription = touchedDataPointPublisher
            .sink {
                let lineMarkerData: [LineMarkerData] = $0.compactMap { data in
                    if data.type == .extraLine,
                       let extraData = self.extraLineData {
                        return LineMarkerData(markerType: extraData.style.markerType,
                                              location: data.location,
                                              dataPoints: extraData.dataPoints.map { LineChartDataPoint($0) },
                                              lineType: extraData.style.lineType,
                                              lineSpacing: .bar,
                                              minValue: extraData.minValue,
                                              range: extraData.range)
                    }
                    return nil
                }
                let barMarkerData: [BarMarkerData] = $0.compactMap { data in
                    if data.type == .bar {
                        return BarMarkerData(markerType: self.touchMarkerType,
                                              location: data.location)
                    }
                    return nil
                }
                self.markerData =  MarkerData(lineMarkerData: lineMarkerData,
                                              barMarkerData: barMarkerData)
            }
        
        internalDataSubscription = touchedDataPointPublisher
            .sink { self.touchPointData = $0.map(\.datapoint) }
    }

    public var average: Double {
        let upperAverage = dataSets.dataPoints
            .map(\.upperValue)
            .reduce(0, +)
            .divide(by: Double(dataSets.dataPoints.count))
        let lowerAverage = dataSets.dataPoints
            .map(\.lowerValue)
            .reduce(0, +)
            .divide(by: Double(dataSets.dataPoints.count))
        return (upperAverage + lowerAverage) / 2
    }
    
    // MARK: Labels
    public func sectionX(count: Int, size: CGFloat) -> CGFloat {
        return divide(size, count)
    }
    
    public func xAxisLabelOffSet(index: Int, size: CGFloat, count: Int) -> CGFloat {
        return CGFloat(index) * divide(size, count)
    }
    
    // MARK: - Touch
    public func setTouchInteraction(touchLocation: CGPoint, chartSize: CGRect) {
        self.infoView.isTouchCurrent = true
        self.infoView.touchLocation = touchLocation
        self.infoView.chartSize = chartSize
        self.processTouchInteraction(touchLocation: touchLocation, chartSize: chartSize)
    }
    
    private func processTouchInteraction(touchLocation: CGPoint, chartSize: CGRect) {
        let xSection: CGFloat = chartSize.width / CGFloat(dataSets.dataPoints.count)
        let index: Int = Int((touchLocation.x) / xSection)
        if index >= 0 && index < dataSets.dataPoints.count {
            let datapoint = dataSets.dataPoints[index]
            let value = CGFloat((dataSets.dataPoints[index].upperValue + dataSets.dataPoints[index].lowerValue) / 2) - CGFloat(self.minValue)
            let location = CGPoint(x: (CGFloat(index) * xSection) + (xSection / 2),
                           y: (chartSize.size.height - (value / CGFloat(self.range)) * chartSize.size.height))
            
            var values: [PublishedTouchData<DataPoint>] = []
            values.append(PublishedTouchData(datapoint: datapoint, location: location, type: chartType.chartType))
            
            if let extraLine = extraLineData?.pointAndLocation(touchLocation: touchLocation, chartSize: chartSize),
               let location = extraLine.location,
               let value = extraLine.value,
               let description = extraLine.description,
               let _legendTag = extraLine._legendTag
            {
                var datapoint = DataPoint(value: value, description: description)
                datapoint._legendTag = _legendTag
                values.append(PublishedTouchData(datapoint: datapoint, location: location, type: .extraLine))
            }
            
            touchedDataPointPublisher.send(values)
        }
    }
    
    public func getTouchInteraction(touchLocation: CGPoint, chartSize: CGRect) -> some View {
        markerSubView(markerData: markerData, chartSize: chartSize, touchLocation: touchLocation)
    }
    
    public func touchDidFinish() {
        touchPointData = []
        infoView.isTouchCurrent = false
    }
    
    public typealias SetType = RangedBarDataSet
    public typealias DataPoint = RangedBarDataPoint
    public typealias Marker = BarMarkerType
}

// MARK: Position
extension RangedBarChartData {
    func getBarPositionX(dataPoint: RangedBarDataPoint, height: CGFloat) -> CGFloat {
        let value = CGFloat((dataPoint.upperValue + dataPoint.lowerValue) / 2) - CGFloat(self.minValue)
        return (height - (value / CGFloat(self.range)) * height)
    }
}
