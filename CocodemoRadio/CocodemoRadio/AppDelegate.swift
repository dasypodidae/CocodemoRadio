
import UIKit

import UserNotifications

import Cast
import Timetable
import Shitaraba

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func setupTabBar() {
        // MARK: タブ設定
        guard let tabBarController = window?.rootViewController as? UITabBarController else {
            return
        }
        let shitarabaVC = ShitarabaTableViewController.make()
        let castVC = RadioCastTableViewController.make()
        let timetableVC = TimetableViewController.make()
        tabBarController.setViewControllers([timetableVC.navigationController!, shitarabaVC.navigationController!, castVC.navigationController!], animated: false)
        tabBarController.selectedViewController = timetableVC.navigationController!
        
        // MARK: 関連url
        shitarabaVC.relatedURL = {
            return CastSetting.url
        }
        // MARK: 番組表の関連urlを開く
        timetableVC.openCommunicationSite = { [weak shitarabaVC] urlString in
            guard let nc = shitarabaVC?.navigationController else {
                return
            }
            do {
                try shitarabaVC?.open(bbsString: urlString)
                tabBarController.selectedViewController = nc
                nc.popToRootViewController(animated: false)
            } catch {
                if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, completionHandler: nil)
                } else {
                    // error処理
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupLocalNotification()
        setupTabBar()
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Swift.Void) {
        print("handleEventsForBackgroundURLSession: \(identifier)")
        // MARK: バックグランウンドで番組表の更新と、ラジオのダウンロードをするのに必要。
        guard BackgroundTrigger.shared.handleEventsForBackgroundURLSession(identifier: identifier, handler: completionHandler) == false else {
            return
        }
        guard RadioDownloder.shared.handleEventsForBackgroundURLSession(identifier: identifier, handler: completionHandler) == false else {
            return
        }
        completionHandler()
    }
}



extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        // MARK: ローカル通知をフォアグラウンドで受け取った時の処理。
        completionHandler([.alert, .sound])
    }
    
    func setupLocalNotification() {
        // MARK: 通知許可のお伺いと、フォアグラウンドで通知を表示するためにdelegateを設定
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if error != nil {
                return
            }
            if granted {
            } else {
            }
        }
        center.delegate = self
    }
}

