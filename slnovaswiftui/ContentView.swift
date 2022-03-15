//
//  ContentView.swift
//  slnovaswiftui
//
//  Created by Jcwang on 2022/3/10.
//

import SwiftUI
import SwiftUICharts
import RMQClient

var trainingHost = [String]()
var epochIndex = [Int: Int]()   // 指示每一个epoch，有多少个主机已经训练好了
var schedulerIndex = 0

var conn: RMQConnection!

func getRabbitMQUrl() -> String{
    var components = URLComponents()
    components.scheme = "amqp"
    components.host = "116.62.233.27"
    components.user = "rabbit"
    components.password = "password"
    components.port = 5672
    components.path = "/vhost"
    let url = components.url?.absoluteString ?? "-"
    print("RabbitMQ URL \(url)")
    return url
}

func sendFanoutMessage(message: String) {
    print("aaa")
    let delegate = RMQConnectionDelegateLogger() // implement RMQConnectionDelegate yourself to react to errors
    // "amqp://username:password@hostName:port/virtualHost"
    // https://juejin.cn/post/6948322270989254664
    print("bbb")
    let conn = RMQConnection(uri: getRabbitMQUrl(), delegate: delegate)
    
    print("ccc")
    conn.start()
    print("ddd")
    let ch = conn.createChannel()
    print("eee")
    
    
//        let q = ch.queue("ml_queue")
//        let exchange = ch.direct("ml_exchange") // 这个返回exchange
//        q.bind(exchange, routingKey: "ml_routing_key")
//
////        q.subscribe({ m in
////           print("Received: \(String(data: m.body, encoding: String.Encoding.utf8))")
////        })
//        q.publish("start train".data(using: String.Encoding.utf8)!)
    
    print("fff")
    let x = ch.fanout("ml_fanout_exchange") // “无路由交换机”，使用这个交换机不需要routingkey绑定，fanout交换机直接绑定了队列
    print("ggg")
    x.publish(message.data(using: String.Encoding.utf8)!)
    

//        let q = ch.queue("ml_quene", options: .durable)
//        q.bind(x)
//        print("Waiting for logs.")
//        q.subscribe({(_ message: RMQMessage) -> Void in
//            print("Received \(String(describing: String(data: message.body, encoding: .utf8)))")
//        })
    
    print("hhh")
    conn.close()
    print("iii")
}



struct ContentView: View {
    @State var presentAlert: Bool = false
    @State var date1 = Date()

    @State var hostStates = [HostState]()
    
//    var timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(scheGetHostStates), userInfo: nil, repeats: true)
    let timer = TimePublisher()
    @State var gridLayout: [GridItem] = [GridItem(.adaptive(minimum: 300, maximum: 500), spacing: 50)]
    
    
    
    
    
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: self.gridLayout, spacing: 50) {
                    ForEach(hostStates, id: \.self) { hostState in
                        
                        HostStateView(hostState: hostState)
                            .foregroundColor(Color(.systemBackground))
    //                    Text("\(date1)")
                    }
                }
                .padding(.leading, 40)
                .padding(.trailing, 40)
                .onReceive(timer.currentTimePublisher) { currentTime in
    //                hostStates.insert(HostState(uuid: "\(i)", diskAllocationRatio: 2, name: "2", ip: "2", totalDiskGB: 4, totalMemoryGB: 4, gpuTotalMemoryGB: 4, cpu_max_freq: 5, time: "!@3123", cpuPercent: 1, usedDiskGB: 1, usedMemoryGB: 1, gpuUsedMemoryGB: 1, cpuCurrentFreq: 1, highVul: 1, mediumVul: 1, lowVul: 1, infoVul: 1, modelSizeMB: 1, loss: 1, accuracy: 1, epoch: 1, isAggregating: true, isTraining: true), at: 0)
    //                date1 = currentTime
    //                for host in tempHostStates {
    //                    if !hostStates.contains(where: {myHost in myHost.uuid == host.uuid}) {
    //                        hostStates.insert(host, at: 0)
    //                    }
    //                }
                    hostStates = scheGetHostStates()
                    
                    print(hostStates.count)
                }
                
            }
            .navigationTitle("HostStates")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button {
                    presentAlert = true
                } label: {
                    Text("开始训练")
                }
                .alert(isPresented: $presentAlert, content: {
                Alert(title: Text("Start train?"), message: Text("It will make all hosts start to train"), primaryButton: .default(Text("OK"), action: {
                    sendFanoutMessage(message: "start train")
                }), secondaryButton: .cancel())
            })
            )
                
            .onAppear {
                let _ = connectMySQL()
                
                let delegate = RMQConnectionDelegateLogger() // implement RMQConnectionDelegate yourself to react to errors
                conn = RMQConnection(uri: getRabbitMQUrl(), delegate: delegate)
                
                conn.start()
                let ch = conn.createChannel()

                let x = ch.fanout("ml_fanout_exchange") // “无路由交换机”，使用这个交换机不需要routingkey绑定，fanout交换机直接绑定了队列

                let q = ch.queue("", options: .durable)
                q.bind(x)

                q.subscribe({(_ message: RMQMessage) -> Void in
                    let str = String(data: message.body, encoding: .utf8) ?? "no data"
                    if let message = str.stringValueDic() {
                        print(message)
                        
                        let epoch = message["epoch"] as! Int
                        let uuid = message["uuid"] as! String
                        let isStart = message["start"] as! Int == 1 ? true : false
                        let finished = message["finished"] as! Int == 1 ? true : false
                        let scheduler = message["scheduler"] as! Int == 1 ? true : false
                        
                        // 发送消息的时候保证都正确，下面的if就只会执行一个
                        if (isStart && !trainingHost.contains(uuid)) {
                            trainingHost.append(uuid)
                        }
                        if (finished) {
                            trainingHost.removeAll(keepingCapacity: true)
                            schedulerIndex = 0
                        }
                        if (scheduler) {
                            schedulerIndex += 1
                            if (schedulerIndex == trainingHost.count) {
                                sendFanoutMessage(message: "start scheduler")
                                schedulerIndex = 0
                            }
                        }
                        if (epoch != -1) {
                            if let _ = epochIndex[epoch] {
                                epochIndex[epoch]! += 1;
                            } else {
                                epochIndex[epoch] = 1;
                            }
                            if (epochIndex[epoch] == trainingHost.count) {
                                sendFanoutMessage(message: "next epoch")
                                epochIndex[epoch] = 0
                            }
                        }
                        
                    }
                })
                
                print("hhh")
        //        conn.close()
                print("iii")
            }
            .onDisappear {
                disconMySQL()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
