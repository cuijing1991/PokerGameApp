//
//  MPCManager.swift
//  MPCRevisited
//
//  Created by Jing Cui on 11/1/15.
//  Copyright © 2015 Jingplusplus. All rights reserved.
//

import UIKit
import MultipeerConnectivity


protocol MPCManagerDelegate1 {
    func foundPeer()
    
    func lostPeer()
    
    func connectedWithPeer(peerID: MCPeerID)
}
protocol MPCManagerDelegate2 {
    func invitationWasReceived(fromPeer: String)
}


class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {

    var delegate1: MPCManagerDelegate1?
    var delegate2: MPCManagerDelegate2?
    
    var sessions = [MCSession!]()
    
    var peer: MCPeerID!
    
    var browser: MCNearbyServiceBrowser!
    
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    
    var invitationHandler: ((Bool, MCSession)->Void)!
    
    var connectedSessionCount = 0
  
    var server: Bool = true
  
    override init() {
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.currentDevice().name)
        
        sessions = [MCSession!](count:3, repeatedValue: nil)
        
        for index in 0...2 {
            sessions[index] = MCSession(peer: peer)
        }
        
        for session: MCSession! in sessions {
            session.delegate = self
        }
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: "appcoda-mpc")
        browser.delegate = self
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: "appcoda-mpc")
        advertiser.delegate = self
    }
    
    
    // MARK: MCNearbyServiceBrowserDelegate method implementation
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
        
        delegate1?.foundPeer()
    }
    
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerate(){
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        
        delegate1?.lostPeer()
    }
    
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print(error.localizedDescription)
    }
    
    
    // MARK: MCNearbyServiceAdvertiserDelegate method implementation
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: ((Bool, MCSession) -> Void)) {
        
        self.invitationHandler = invitationHandler
        
        delegate2?.invitationWasReceived(peerID.displayName)
    }
    
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print(error.localizedDescription)
    }
    
    
    // MARK: MCSessionDelegate method implementation
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        switch state{
        case MCSessionState.Connected:
            print("Connected to session: \(session)")
            delegate1?.connectedWithPeer(peerID)
            
        case MCSessionState.Connecting:
            print("Connecting to session: \(session)")
            
        default:
            print("Did not connect to session: \(session)")
        }
    }
    
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        let dictionary: [String: AnyObject] = ["data": data, "fromPeer": peerID]
        NSNotificationCenter.defaultCenter().postNotificationName("receivedMPCDataNotification", object: dictionary)
    }
    
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) { }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) { }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: ((Bool) -> Void)) {
        print("Made first contact with peer and have identity information about the remote peer (certificate may be nil)")
        certificateHandler(true)
    }
    
    // MARK: Custom method implementation
    
//    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
//        let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(dictionary)
//        var peersArray = [MCPeerID]()
//        peersArray.append(targetPeer)
//        
//        
//        for session: MCSession! in sessions {
//        
//            do {
//                try session.sendData(dataToSend, toPeers: peersArray, withMode: MCSessionSendDataMode.Reliable)
//            }
//            catch let error as NSError {
//                print(error.localizedDescription)
//                return false
//            }
//        }
//        return true
//    }
    
//    func sendData(dictionaryWithCard dictionary: Dictionary<String, AnyObject>, toPeer targetPeer: MCPeerID) -> Bool {
//        let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(dictionary)
//        var peersArray = [MCPeerID]()
//        peersArray.append(targetPeer)        
//        
//        for session: MCSession! in sessions {
//            
//            do {
//                try session.sendData(dataToSend, toPeers: peersArray, withMode: MCSessionSendDataMode.Reliable)
//            }
//            catch let error as NSError {
//                print(error.localizedDescription)
//                return false
//            }
//        }
//        return true
//    }

}
