//
//  HostState.swift
//  slnovaswiftui
//
//  Created by Jcwang on 2022/3/10.
//

import Foundation
import SwiftUI

struct HostState: Hashable, Identifiable {
    // ForEach中需要遵循Identifiable，这样就不用提供ID了，然后我让这个id等于我的uuid
    var id: String {uuid}
    
    // 不变
    var uuid = ""
    var diskAllocationRatio = 0.0
    var name = "nullname"
    var ip = "0.0.0.0"
    
    var totalDiskGB = 0.0
    var totalMemoryGB = 0.0
    var gpuTotalMemoryGB = 0.0
    var cpu_max_freq = 0.0
    
    
    // 变
    var time = "1970-00-00 00:00:00"
    var cpuPercent = 0.0
    
    var usedDiskGB = 0.0
    var usedMemoryGB = 0.0
    var gpuUsedMemoryGB = 0.0
    var cpuCurrentFreq = 0.0
    
    var highVul = 0
    var mediumVul = 0
    var lowVul = 0
    var infoVul = 0
    
    var modelSizeMB = 0.0
    var loss = 0.0
    var accuracy = 0.0
    // 显示的时候从0开始，存储的时候，也是从0开始存储的，因为训练的时候26，101这样，为了每5次存储时首位都存储
    var epoch = (-1)
    var isAggregating = false
    var isTraining = false
    
    // 这个color只不过是我显示颜色的时候设置的
    var myBackgroundColor: Color = Color(.systemBackground)
    
    init(uuid: String,
         diskAllocationRatio: Double,
         name: String,
         ip: String,
         totalDiskGB: Double,
         totalMemoryGB: Double,
         gpuTotalMemoryGB: Double,
         cpu_max_freq: Double,
         time: String,
         cpuPercent: Double,
         usedDiskGB: Double,
         usedMemoryGB: Double,
         gpuUsedMemoryGB: Double,
         cpuCurrentFreq: Double,
         highVul: Int=0,
         mediumVul: Int=0,
         lowVul: Int=0,
         infoVul: Int=0,
         modelSizeMB: Double,
         loss: Double,
         accuracy: Double,
         epoch: Int=0,
         isAggregating: Bool=false,
         isTraining: Bool=false) {

        // 不变
        self.uuid = uuid
        self.diskAllocationRatio = diskAllocationRatio
        self.name = name
        self.ip = ip

        self.totalDiskGB = totalDiskGB
        self.totalMemoryGB = totalMemoryGB
        self.gpuTotalMemoryGB = gpuTotalMemoryGB
        self.cpu_max_freq = cpu_max_freq


        // 变
        self.time = time
        self.cpuPercent = cpuPercent

        self.usedDiskGB = usedDiskGB
        self.usedMemoryGB = usedMemoryGB
        self.gpuUsedMemoryGB = gpuUsedMemoryGB
        self.cpuCurrentFreq = cpuCurrentFreq

        self.highVul = highVul
        self.mediumVul = mediumVul
        self.lowVul = lowVul
        self.infoVul = infoVul

        self.modelSizeMB = modelSizeMB
        self.loss = loss
        self.accuracy = accuracy
        self.epoch = epoch
        self.isAggregating = isAggregating
        self.isTraining = isTraining
        
//        self.myBackgroundColor = Color(.systemBackground)
////        // 检查如果是时间格式
////        // 因为数据库存进去，读取出来，都需要时间，所以显示的时间都会比实际时间晚的。
        if (self.time.count == 19) {
            let localTime = Helper.getAllSeconds(time: Helper.getCurrentTime())
            let mysqlTime = Helper.getAllSeconds(time: self.time)

            // 训练用红色，聚合用橙色，运行蓝色，不活跃状态背景色
            if (mysqlTime - 3 < localTime && localTime <= mysqlTime + 4) {
                self.myBackgroundColor = .blue.opacity(0.6)
                if self.isTraining {
                    self.myBackgroundColor = .red.opacity(0.6)
                }
                // 聚合为true的时候，training肯定是true的
                if self.isAggregating {
                    self.myBackgroundColor = .orange.opacity(0.6)

                }
            }
        }
    }
    
    func description() -> String {
        // 为了使得文本看起来空的差不多，我需要留出一些空格
        return """
                  \(self.time)
                  
                  cpu使用率：     \(String(format:"%.2f", self.cpuPercent))%
                  cpu频率： \(String(format:"%.4f", self.cpuCurrentFreq))GHz(\(String(format:"%.2f", self.cpu_max_freq))GHz)
                  磁盘：    \(String(format:"%.2f", self.usedDiskGB))GB(\(String(format:"%.2f", self.totalDiskGB))GB)
                  内存：    \(String(format:"%.2f", self.usedMemoryGB))GB(\(String(format:"%.2f", self.totalMemoryGB))GB)
                  显存：    \(String(format:"%.2f", self.gpuUsedMemoryGB))GB(\(String(format:"%.2f", self.gpuTotalMemoryGB))GB)
                  安全：                 \(self.infoVul)个
                  低风险漏洞：    \(self.lowVul)个
                  中风险漏洞：    \(self.mediumVul)个
                  高风险漏洞：    \(self.highVul)个
                  模型大小：      \(String(format:"%.2f", self.modelSizeMB))
                  损失值：          \(String(format:"%.4f", self.loss))
                  准确率：          \(String(format:"%.4f", self.accuracy))
                  训练轮数：      第\(epoch)轮
                  正在聚合：      \(isAggregating)
                  正在训练：      \(isTraining)
                  uuid：
                  \(self.uuid)
                  """
    }
}
