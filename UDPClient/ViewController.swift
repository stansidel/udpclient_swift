//
//  ViewController.swift
//  UDPClient
//
//  Created by Stanislav Sidelnikov on 17/02/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController, GCDAsyncUdpSocketDelegate {
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var localPortTextField: UITextField!
    @IBOutlet weak var remotePortTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var answerTextView: UITextView!
    
    var _socket: GCDAsyncUdpSocket?
    var socket: GCDAsyncUdpSocket? {
        get {
            if _socket == nil {
                guard let port = UInt16(localPortTextField.text ?? "0") where port > 0 else {
                    log(">>> Unable to init socket: local port unspecified.")
                    return nil
                }
                let sock = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
                do {
                    try sock.bindToPort(port)
                    try sock.beginReceiving()
                } catch let err as NSError {
                    log(">>> Error while initializing socket: \(err.localizedDescription)")
                    sock.close()
                    return nil
                }
                _socket = sock
            }
            return _socket
        }
        set {
            _socket?.close()
            _socket = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    deinit {
        socket = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func log(text: String) {
        answerTextView.text = text + "\n" + answerTextView.text
    }

    @IBAction func sendPacket(sender: AnyObject) {
        guard let str = messageTextField.text where !str.isEmpty else {
            log(">>> Cannot send packet: no data inserted")
            return
        }
        guard let host = hostTextField.text where !host.isEmpty else {
            log(">>> Cannot send packet: no host specified")
            return
        }
        guard let port = UInt16(remotePortTextField.text ?? "0") where port > 0 else {
            log(">>> Cannot send packet: no port specified")
            return
        }
        
        guard socket != nil else {
            return
        }
        socket?.sendData(str.dataUsingEncoding(NSUTF8StringEncoding), toHost: host, port: port, withTimeout: 2, tag: 0)
        log("Data sent: \(str)")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        guard let stringData = String(data: data, encoding: NSUTF8StringEncoding) else {
            log(">>> Data received, but cannot be converted to String")
            return
        }
        log("Data received: \(stringData)")
    }

}

