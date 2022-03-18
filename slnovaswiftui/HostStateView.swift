//
//  HostStateView.swift
//  slnovaswiftui
//
//  Created by Jcwang on 2022/3/10.
//

import SwiftUI
import SwiftUICharts

struct HostStateView: View {
    var hostState: HostState
    
    var body: some View {
        ZStack {
            
//            RoundedRectangle(cornerRadius: 16, style: .continuous)
//                .shadow(color: ., radius: <#T##CGFloat#>, x: <#T##CGFloat#>, y: <#T##CGFloat#>)
            
//            RoundedRectangle(cornerRadius: 16, style: .continuous)
//                .fill(Color(.systemBackground))
//                .shadow(color: .gray, radius: 16, x: 6, y: 6)
                
//                .fill(Color(.systemBackground))
            
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(hostState.myBackgroundColor)
                .shadow(color: .gray, radius: 16, x: 6, y: 6)
            
            
            VStack(alignment: .leading, spacing: 1) {
                Text(hostState.name).font(.title2).foregroundColor(Color(.label))
                    .padding(.bottom, 5)
                    .padding(.top, 3)
                Text(hostState.ip).font(.title3).foregroundColor(.gray)
                    .padding(.bottom, 3)
                Text(hostState.time).font(.title3).foregroundColor(Color(.label))
                    .padding(.bottom, 3)
                
                Text("CPU使用率: \(String(format:"%.2f", hostState.cpuPercent))%").foregroundColor(Color(.label))
                    .font(.body)
                    .padding(.bottom, 5)
                
                ProgressView("磁盘: \(String(format:"%.2f", hostState.usedDiskGB))(\(String(format:"%.2f", hostState.totalDiskGB)))GB", value: hostState.usedDiskGB, total: hostState.totalDiskGB)
                    .progressViewStyle(MyProgressViewStyle())
                    .padding(.bottom, 3)
                ProgressView("内存: \(String(format:"%.2f", hostState.usedMemoryGB))(\(String(format:"%.2f", hostState.totalMemoryGB)))GB", value: hostState.usedMemoryGB, total: hostState.totalMemoryGB)
                    .progressViewStyle(MyProgressViewStyle())
                    .padding(.bottom, 3)
                ProgressView("显存: \(String(format:"%.2f", hostState.gpuUsedMemoryGB))(\(String(format:"%.2f", hostState.gpuTotalMemoryGB)))GB", value: hostState.gpuUsedMemoryGB, total: hostState.gpuTotalMemoryGB)
                    .progressViewStyle(MyProgressViewStyle())
                    .padding(.bottom, 10)
                HStack {
//                    PieChartView(data: [Double(hostState.infoVul), Double(hostState.lowVul), Double(hostState.mediumVul), Double(hostState.highVul)], title: "风险等级", legend: nil, style: .init(backgroundColor: Color(.systemBackground), accentColor: .blue, gradientColor: .init(start: .blue, end: .orange), textColor: Color(.label), legendTextColor: .black, dropShadowColor: .gray), form: ChartForm.medium, dropShadow: true)
//                    BarChartView(data: ChartData(values: [("ad", 21), ("ew", 24)]), title: "213", legend: "qwe", dropShadow: true, cornerImage: nil, animatedToBack: false)
//                    MultiLineChartView(data: [
//                        ([0, 0, 0], GradientColor(start: .teal, end: .pink)),
//                        ([1, 2, 3], GradientColor(start: .blue, end: .green))
//                    ], title: "Multi Line")
                    
//                    LineChart()
//                        .data([("asd", 12), ("aaa", 13)])
//                        .chartStyle(ChartStyle(backgsroundColor: .white,
//                                                       foregroundColor: ColorGradient(.blue, .purple)))
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(hostState.myBackgroundColor)
                            .shadow(color: .gray, radius: 8, x: 3, y: 3)
                        VStack {
                            Text("第 \(hostState.epoch) 轮").foregroundColor(Color(.label))
                                .padding(.top, 3)
                            Text("损失值：\(String(format:"%.2f", hostState.loss))").foregroundColor(Color(.label))
                            Text("准确率：\(String(format:"%.2f", hostState.accuracy))").font(.body).foregroundColor(Color(.label))
                            Text("模型大小：\(String(format:"%.2f", hostState.modelSizeMB))").font(.body).foregroundColor(Color(.label))
                                .padding(.bottom, 3)
                        }
                    }
                    
                    CardView(showShadow: false) {
                        ChartLabel("风险等级", type: .custom(size: 12, padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0), color: Color(.label)))
                        PieChart()
                    }
                    .data([("安全", Double(hostState.infoVul+1)), ("低", Double(hostState.lowVul+1)), ("中", Double(hostState.mediumVul+2)), ("高", Double(hostState.highVul+3))])
                    .chartStyle(ChartStyle(backgroundColor: .white,
                                           foregroundColor: ColorGradient(.teal, .yellow)))
                    
                }
                
                Text("uuid: \(hostState.uuid)").font(.caption).foregroundColor(Color(.label))
                    .padding(.top, 8)
                    .padding(.bottom, 3)
            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
        }
        
    }
}






//定义方法都大同小异。
struct MyProgressViewStyle: ProgressViewStyle{
    let foregroundColor:Color
    let backgroundColor:Color
    init(foregroundColor:Color = .blue,backgroundColor:Color = .orange) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader{ proxy in
            ZStack(alignment:.topLeading){
            backgroundColor
            Rectangle()
                .fill(foregroundColor)
                .frame(width:proxy.size.width * CGFloat(configuration.fractionCompleted ?? 0.0))
            }.clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                    configuration.label
                        .foregroundColor(.white)
            )
        }.frame(height: 20)
    }
}



struct HostStateView_Previews: PreviewProvider {
    static var previews: some View {
        HostStateView(hostState: HostState(uuid: "asd", diskAllocationRatio: 1.1, name: "!@3", ip: "!23", totalDiskGB: 1, totalMemoryGB: 2, gpuTotalMemoryGB: 2, cpu_max_freq: 2, time: "2", cpuPercent: 2, usedDiskGB: 2, usedMemoryGB: 2, gpuUsedMemoryGB: 2, cpuCurrentFreq: 2, highVul: 2, mediumVul: 2, lowVul: 2, infoVul: 2, modelSizeMB: 2, loss: 2, accuracy: 2, epoch: 2, isAggregating: true, isTraining: true))
.previewInterfaceOrientation(.portrait)
    }
}






