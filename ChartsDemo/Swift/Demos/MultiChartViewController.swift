//
//  MultiChartViewController.swift
//  ChartsDemo
//
//  Created by Kushal Ashok on 1/17/18.
//  Copyright © 2018 dcg. All rights reserved.
//

import UIKit
import Charts

// Screen width.
public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height
}

class MultiChartViewController: DemoBaseViewController {
    
    var numberOfRows = 2
    var numberOfColumns = 3
    var arrayOfChartsVertical: [[BarChartView]]!
    var rowsTextField: UITextField!
    var columnsTextField: UITextField!
    var submitButton: UIButton!
    var chartScrollView: UIScrollView!
    var effectiveScreenHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.title = "Multiple Chart Rows"
        
        if let navBarHeight = self.navigationController?.navigationBar.frame.size.height {
            effectiveScreenHeight = screenHeight - navBarHeight
        } else {
            effectiveScreenHeight = screenHeight
        }
        
        rowsTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        rowsTextField.backgroundColor = UIColor.lightGray
        
        columnsTextField = UITextField(frame: CGRect(x: 120, y: 0, width: 100, height: 40))
        columnsTextField.backgroundColor = UIColor.lightGray
        
        submitButton = UIButton(frame: CGRect(x: 340, y: 0, width: 100, height: 40))
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(UIColor.blue, for: .normal)
        submitButton.addTarget(self, action:#selector(submitButtonTapped(sender:)), for: .touchUpInside)
        
        chartScrollView = UIScrollView(frame: CGRect(x: 0, y: 50, width: screenWidth, height: effectiveScreenHeight - 50))
        chartScrollView.backgroundColor = UIColor.clear
        chartScrollView.contentSize = CGSize(width: chartScrollView.frame.size.width*2, height: chartScrollView.frame.size.height)
        
        self.view.addSubview(rowsTextField)
        self.view.addSubview(columnsTextField)
        self.view.addSubview(submitButton)
        self.view.addSubview(chartScrollView)
        
        drawCharts()
    }
    
    func drawCharts() {
        arrayOfChartsVertical = []
        for _ in 1...numberOfRows   {
            var arrayOfChartsHorizontal = [BarChartView()]
            for _ in 2...numberOfColumns {
                arrayOfChartsHorizontal.append(BarChartView())
            }
            arrayOfChartsVertical.append(arrayOfChartsHorizontal)
        }
        
        var yCoordinate:CGFloat = 0
        var xCoordinate:CGFloat = 0
        let chartWidth = chartScrollView.frame.size.width*2/CGFloat(numberOfColumns)
        let chartHeight = chartScrollView.frame.size.height/CGFloat(numberOfRows)
        
        for horizontalArray in arrayOfChartsVertical {
            for chartViewItem in horizontalArray {
                chartScrollView.addSubview(chartViewItem)
                chartViewItem.frame = CGRect(x: xCoordinate, y: yCoordinate, width: chartWidth, height: chartHeight)
                setupChart(chartViewItem)
                updateChartData(chartViewItem)
                xCoordinate += chartWidth
            }
            xCoordinate = 0
            yCoordinate += chartHeight
        }
    }
    
    @objc func submitButtonTapped(sender: UIButton) {
        for view in chartScrollView.subviews {
            view.removeFromSuperview()
        }
        guard let rowsText = rowsTextField.text, let columnsText = columnsTextField.text else {return}
        guard let rowsNumber = Int(rowsText), let columnsNumber = Int(columnsText) else {return}
        numberOfRows = rowsNumber
        numberOfColumns = columnsNumber
        drawCharts()
    }
    
    func setupChart(_ chartView:BarChartView) {
        self.setup(barLineChartView: chartView)
        
        chartView.delegate = self
        
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        
        chartView.maxVisibleCount = 60
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        xAxis.valueFormatter = DayAxisValueFormatter(chart: chartView)
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = " $"
        leftAxisFormatter.positiveSuffix = " $"
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0 // FIXME: HUH?? this replaces startAtZero = YES
        
        let legend = chartView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.drawInside = true
        legend.form = .square
        legend.formSize = 15
        legend.font = UIFont(name: "HelveticaNeue-Light", size: 15)!
        legend.xEntrySpace = 4
        legend.yEntrySpace = 10
        
        let marker = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
                                  font: .systemFont(ofSize: 12),
                                  textColor: .white,
                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                  xAxisValueFormatter: chartView.xAxis.valueFormatter!)
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker
    }
    
    func updateChartData(_ chartView: BarChartView) {
        if self.shouldHideData {
            chartView.data = nil
            return
        }
        self.setDataCount(12 + 1, range: UInt32(50), chartView: chartView)
    }
    
    func setDataCount(_ count: Int, range: UInt32, chartView:BarChartView) {
        let start = 1
        
        let yVals = (start..<start+count+1).map { (i) -> BarChartDataEntry in
            let mult = range + 1
            let val = Double(arc4random_uniform(mult))
            if arc4random_uniform(100) < 25 {
                return BarChartDataEntry(x: Double(i), y: val, icon: UIImage(named: "icon"))
            } else {
                return BarChartDataEntry(x: Double(i), y: val)
            }
        }
        
        var set1: BarChartDataSet! = nil
        if let set = chartView.data?.dataSets.first as? BarChartDataSet {
            set1 = set
            set1.values = yVals
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            set1 = BarChartDataSet(values: yVals, label: "The year 2017")
            set1.colors = ChartColorTemplates.material()
            set1.drawValuesEnabled = false
            
            let data = BarChartData(dataSet: set1)
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            data.barWidth = 0.9
            chartView.data = data
        }
        
        //        chartView.setNeedsDisplay()
    }
    
}

