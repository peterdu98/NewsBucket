//
//  ChartCell.swift
//  NewsBucket
//
//  Created by Peter Du on 24/5/20.
//  Copyright © 2020 Peter Du. All rights reserved.
//

import UIKit
import Charts

class ChartCell: UICollectionViewCell, ChartViewDelegate {
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    var chartLabel: String?
    var categories: [String] = []
    var numNews: [Double]? {
        didSet {
            layoutCell()
        }
    }
    
    var barChart = BarChartView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        barChart.delegate = self
        axisFormatDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Customised layout
    private func layoutCell() {
        let label: UILabel = {
            let item = UILabel()
            item.text = chartLabel
            item.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
            item.translatesAutoresizingMaskIntoConstraints = false
            return item
        }()
        
        barChart.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(barChart)
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            barChart.heightAnchor.constraint(equalToConstant: self.frame.height - 30.0),
            barChart.widthAnchor.constraint(equalToConstant: self.frame.width),
            barChart.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            barChart.topAnchor.constraint(equalTo: label.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: barChart.topAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        ])
        
        if numNews!.count == 0 {
            barChart.noDataText = "You haven't read any news yet."
            barChart.noDataFont = UIFont.systemFont(ofSize: 18.0, weight: .medium)
            barChart.noDataTextColor = UIColor.systemRed
            
        } else {
            setChart(labels: categories, values: numNews!)
        }
    }
    
    //MARK: - Setup BarChart
    private func setChart(labels: [String], values: [Double]) {
        var entries = [BarChartDataEntry]()
        for i in 0..<labels.count {
            let dataEntry = BarChartDataEntry(x: Double(i + 1), y: values[i], data: labels)
            entries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: entries, label: "Number of news")
        chartDataSet.colors = ChartColorTemplates.joyful()
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = 0.5
        
        barChart.data = chartData
        
        let xAxisValue = barChart.xAxis
        xAxisValue.valueFormatter = axisFormatDelegate
        barChart.xAxis.labelCount = labels.count
        
        layoutBarChart()
    }
    
    private func layoutBarChart () {
        barChart.rightAxis.enabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.spaceMin = 0.5
        barChart.xAxis.spaceMax = 0.5
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.xAxis.granularityEnabled = true
        barChart.xAxis.granularity = 1.0
        barChart.xAxis.labelFont = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        barChart.data?.setValueFont(UIFont.systemFont(ofSize: 15.0, weight: .medium))
        barChart.legend.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        barChart.isUserInteractionEnabled = false
        
        barChart.animate(yAxisDuration: 2.0, easingOption: .easeOutExpo)
    }
    
}

//MARK: - Formatter Delegate
extension ChartCell: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return categories[Int(value - 1)]
    }
}
