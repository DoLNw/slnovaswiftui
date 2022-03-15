//
//  ModelData.swift
//  slnovaswiftui
//
//  Created by Jcwang on 2022/3/11.
//

import Foundation
import OHMySQL

// 初始化OHMySQL协调器
var coordinator = MySQLStoreCoordinator()
// 初始化上下文
let context = MySQLQueryContext()

var timer: Timer!

func scheGetHostStates() -> [HostState] {
    return getHostStates(infos: queryMySQL())
//    self.collectionView.reloadData()
}

func connectMySQL() -> Bool {

    let dbName = "slnova"//数据库模块名称
    ///MySQL Server
    let SQLUserName = "root"//数据库用户名
    let SQLPassword = "971707"//数据库密码

    let SQLServerName = "116.62.233.27"
    let SQLServerPort: UInt = 3306
    
    //mac本地socket为/tmp/mysql.sock，远程连接socket直接为nil即可
    let user = OHMySQLUser(user: SQLUserName, password: SQLPassword, serverName: SQLServerName, dbName: dbName, port: SQLServerPort, socket: nil)
    
    coordinator = MySQLStoreCoordinator(configuration: user)
    coordinator.encoding = .UTF8MB4//编码方式
    coordinator.connect()//连接数据库
    
    
    //判断是否成功数据库
    let sqlConnected: Bool = coordinator.isConnected
    // 连接成功后保存协调器到当前的上下文，即可不用每次操作数据库都要重新连接
    if (sqlConnected) {
        print("连接成功")
        context.storeCoordinator = coordinator
        
        return true
    }
    
    return false
}

func disconMySQL() {
    // 与数据库断开连接
    coordinator.disconnect()
}

func queryMySQL() -> [[String: Any]] {
    
    // 表名
    let tableName = "test"

    // SELECT - 查询
    // 查询的请求会返回的数据格式为[[String:Any]]）
    // condition不写，是查询所有，而不是写*号
    let query = MySQLQueryRequestFactory.select(tableName, condition: "")
    do {
        //查询
        let response = try context.executeQueryRequestAndFetchResult(query)
        
        return response
                
     }catch {
         print("MySQL_Error:\(error)")
    }
    
    return [[String: Any]]()
}
// 注意：MySQL数据库拿下来的TEXT数据显示出来是带有ASCII字符串十六进制表示的ANY对象，需要先转成Data然后转成String
// 注意，mysql中text类型的字符串数据，获取方法是String(data: info["uuid"] as! Data, encoding: String.Encoding.utf8) ?? "nulluuid"
// 而如果使用VARCHAR的话，只要转换成String就好了
func getHostStates(infos: [[String: Any]]) -> [HostState] {
    var hosts = [HostState]()
    for info in infos {
        let hostate = HostState(
            uuid: info["uuid"] as! String,
            diskAllocationRatio: (info["disk_allocation_ratio"] as! Double),
            name: info["name"] as! String,
            ip: info["ip"] as! String,
            totalDiskGB: (info["total_disk_gb"] as! Double),
            totalMemoryGB: (info["total_memory_gb"] as! Double),
            gpuTotalMemoryGB: (info["gpu_total_memory_gb"] as! Double),
            cpu_max_freq: (info["cpu_max_freq"] as! Double),
            time: info["time"] as! String,
            cpuPercent: (info["cpu_percent"] as! Double),
            usedDiskGB: (info["used_disk_gb"] as! Double),
            usedMemoryGB: (info["used_memory_gb"] as! Double),
            gpuUsedMemoryGB: (info["gpu_used_memory_gb"] as! Double),
            cpuCurrentFreq: (info["cpu_current_freq"] as! Double),
            highVul: (info["high_vul"] as! Int),
            mediumVul: (info["medium_vul"] as! Int),
            lowVul: (info["low_vul"] as! Int),
            infoVul: (info["info_vul"] as! Int),
            modelSizeMB: (info["model_size_mb"] as! Double),
            loss: (info["loss"] as! Double),
            accuracy: (info["accuracy"] as! Double),
            epoch: (info["epoch"] as! Int),
            isAggregating: (info["is_aggregating"] as! Bool),
            isTraining: (info["is_training"] as! Bool)
        )
        
        hosts.append(hostate)
    }
    
    return hosts
}


