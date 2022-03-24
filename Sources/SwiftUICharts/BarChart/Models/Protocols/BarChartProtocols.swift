//
//  BarChartProtocols.swift
//  
//
//  Created by Will Dale on 02/02/2021.
//

import SwiftUI

// MARK: - Chart Data
/**
 A protocol to extend functionality of `CTLineBarChartDataProtocol` specifically for Bar Charts.
 */
@available(iOS 14.0, *)
public protocol CTBarChartDataProtocol: CTLineBarChartDataProtocol {
    
    associatedtype BarStyle: CTBarStyle
    
    /**
     Overall styling for the bars
     */
    var barStyle: BarStyle { get set }
    
    var animations: BarElementAnimation { get }
}



/**
 A protocol to extend functionality of `CTBarChartDataProtocol` specifically for Multi Part Bar Charts.
 */
@available(iOS 14.0, *)
public protocol CTMultiBarChartDataProtocol: CTBarChartDataProtocol {
    
    /**
     Grouping data to inform the chart about the relationship between the datapoints.
     */
    var groups: [GroupingData] { get set }
}

/**
 A protocol to extend functionality of `CTBarChartDataProtocol` specifically for Multi Part Bar Charts.
 */
@available(iOS 14.0, *)
public protocol CTRangedBarChartDataProtocol: CTBarChartDataProtocol {}

/**
 A protocol to extend functionality of `CTBarChartDataProtocol` specifically for Horizontal Bar Charts.
 */
@available(iOS 14.0, *)
public protocol CTHorizontalBarChartDataProtocol: CTBarChartDataProtocol, isHorizontal {}

@available(iOS 14.0, *)
public protocol isHorizontal {}

// MARK: - Style
/**
 A protocol to extend functionality of `CTLineBarChartStyle` specifically for  Bar Charts.
 */
@available(iOS 14.0, *)
public protocol CTBarChartStyle: CTLineBarChartStyle {}

@available(iOS 14.0, *)
public protocol CTBarStyle: CTBarColourProtocol, Hashable {
    /// How much of the available width to use. 0...1
    var barWidth: CGFloat { get set }
    
    /// Corner radius of the bar shape.
    var cornerRadius: CornerRadius { get set }
    
    /// Where to get the colour data from.
    var colourFrom: ColourFrom { get set }
    
    /// Drawing style of the fill.
    var colour: ChartColour { get set }
}






// MARK: - DataSet
/**
 A protocol to extend functionality of `CTSingleDataSetProtocol` specifically for Standard Bar Charts.
 */
@available(iOS 14.0, *)
public protocol CTStandardBarChartDataSet: CTSingleDataSetProtocol {
    /**
     Label to display in the legend.
     */
    var legendTitle: String { get set }
}

/**
 A protocol to extend functionality of `CTSingleDataSetProtocol` specifically for Multi Part Bar Charts.
 */
@available(iOS 14.0, *)
public protocol CTMultiBarChartDataSet: CTSingleDataSetProtocol  {
    /**
     Title of the data set.
     
     This is used as an x axis label.
     */
    var setTitle: String { get set }
}

/**
 A protocol to extend functionality of `CTSingleDataSetProtocol` specifically for Ranged Bar Charts.
 */
@available(iOS 14.0, *)
public protocol CTRangedBarChartDataSet: CTStandardBarChartDataSet  {}





// MARK: - DataPoints
/**
 A protocol to extend functionality of `CTLineBarDataPointProtocol` specifically for standard Bar Charts.
 
 This is base to specify conformance for generics.
 */
@available(iOS 14.0, *)
public protocol CTBarDataPointBaseProtocol: CTLineBarDataPointProtocol {}

/**
 A protocol to a standard colour scheme for bar charts.
 */
@available(iOS 14.0, *)
public protocol CTBarColourProtocol {
    /// Drawing style of the range fill.
    var colour: ChartColour { get set }
}

/**
 A protocol to extend functionality of `CTBarDataPointBaseProtocol` specifically for standard Bar Charts.
 */
@available(iOS 14.0, *)
public protocol CTStandardBarDataPoint: CTBarDataPointBaseProtocol, CTStandardDataPointProtocol, CTBarColourProtocol, CTnotRanged {}

/**
 A protocol to extend functionality of `CTBarDataPointBaseProtocol` specifically for standard Bar Charts.
 */
@available(iOS 14.0, *)
public protocol CTRangedBarDataPoint: CTBarDataPointBaseProtocol, CTRangeDataPointProtocol, CTBarColourProtocol, CTisRanged {
    var value: Double { get }
}

/**
 A protocol to extend functionality of `CTBarDataPointBaseProtocol` specifically for multi part Bar Charts.
 i.e: Grouped or Stacked
 */
@available(iOS 14.0, *)
public protocol CTMultiBarDataPoint: CTBarDataPointBaseProtocol, CTStandardDataPointProtocol, CTnotRanged {
    
    /**
     For grouping data points together so they can be drawn in the correct groupings.
     */
    var group: GroupingData { get set }
}
