import UIKit
import Capacitor

@objc(MainViewController)
class MainViewController: CAPBridgeViewController {

    private var navigationController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
    }

    private func setupNavigationController() {
        // 将当前 view 包装到 UINavigationController 中
        let nav = UINavigationController()
        nav.viewControllers = [self]

        // 启用边缘滑动返回
        nav.interactivePopGestureRecognizer?.isEnabled = true
        nav.interactivePopGestureRecognizer?.delegate = nil

        // 隐藏导航栏（保持原生返回手势体验）
        nav.isNavigationBarHidden = true

        self.navigationController = nav
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 将 navigationController 设为根视图
        if let nav = navigationController, nav.parent == nil {
            DispatchQueue.main.async {
                nav.modalPresentationStyle = .fullScreen
                if let window = self.view.window {
                    window.rootViewController = nav
                    window.makeKeyAndVisible()
                }
            }
        }
    }

    // 在 view controller 切换时同步 swipe-back 状态
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = self.navigationController != nil
    }
}