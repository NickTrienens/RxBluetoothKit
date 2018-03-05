import RxBluetoothKit
import RxCocoa
import RxSwift
import UIKit

class ScanResultsViewController: UIViewController, CustomView {

    typealias ViewClass = ScanResultsView

    typealias ScansResultDataSource = TableViewDataSource<ScannedPeripheral, ScanResultsViewModelItem>

    private let dataSource: TableViewDataSource<ScannedPeripheral, ScanResultsViewModelItem>

    private let viewModel: ScanResultsViewModelType

    private let disposeBag: DisposeBag = DisposeBag()

    init(with dataSource: ScansResultDataSource, viewModel: ScanResultsViewModelType) {
        self.dataSource = dataSource
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = ViewClass()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customView.setTableView(dataSource: dataSource, delegate: self)
        setDataSourceRefreshBlock()
        registerCells()
        setNavigationBar()
        dataSource.bindNewItems()
        bindRx()
    }

    private func bindRx() {
        viewModel.scanningOutput.bind(to: dataSource.itemsObserver).disposed(by: disposeBag)
    }

    private func setNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start scanning",
                style: .plain,
                target: self,
                action: #selector(scanningAction))
    }

    @objc private func scanningAction() {
        viewModel.scanAction()
        adjustTitle()
        if viewModel.isScanning {
            dataSource.bindNewItems()
        }
    }

    private func adjustTitle() {
        navigationItem.rightBarButtonItem?.title = viewModel.isScanning ? "Stop scan" : "Start scan"
        title = viewModel.isScanning ? "Scanning" : nil
    }

    private func setDataSourceRefreshBlock() {
        self.dataSource.refreshDataBlock = { [weak self] in
            self?.customView.refreshTableView()
        }
    }

    private func registerCells() {
        customView.tableView.register(ScanResultTableViewCell.self,
                forCellReuseIdentifier: String(describing: ScanResultTableViewCell.self))
    }
}

extension ScanResultsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}