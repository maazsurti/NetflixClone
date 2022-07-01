//
//  HomeViewController.swift
//  Netflix
//
//  Created by Maaz on 25/03/22.
//

import UIKit
import FirebaseAuth
import Firebase
import JGProgressHUD

enum Section: Int {
    case TrendingMovies = 0
    case TrendingTV = 1
    case Popular = 2
    case Upcoming = 3
    case TopRated = 4
}

class HomeViewController: UIViewController {    
    
    var handle: AuthStateDidChangeListenerHandle?
    
    var didLogIn: Bool = false
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var userToken: Firebase.User?
    
    private var randomTrendingMovie: Title?
    
    private let sectionTitles: [String] =  ["Trending Movies", "Trending TV", "Popular", "Upcoming Movies", "Top Rated"]
    
    private var headerView: HeroHeaderUIView?
    
    private let homeFeedTable: UITableView = {
        
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self, forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCurrentUserToken()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let handle = handle else {
            return
        }
        
        Auth.auth().removeStateDidChangeListener(handle)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup
        view.backgroundColor = .systemBackground
        
        userStateListener()
        getCurrentUserToken()
        configureNavbar()
        configureHeroHeaderView()
        
        
        headerView =  HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        homeFeedTable.tableHeaderView = headerView
        
        
        homeFeedTable.dataSource = self
        homeFeedTable.delegate = self
        
        // Adding subviews
        view.addSubview(homeFeedTable)
        
        print("DEBUG: The user token is : \(String(describing:userToken))")
        
    }
    
    private func configureHeroHeaderView() {
        APICaller.shared.getTrendingMovies{ [weak self] result in
            switch result {
            case .success(let titles):
                
                let selectedTitle = titles.randomElement()
                
                self?.randomTrendingMovie = titles.randomElement()
                self?.headerView?.configure(with: TitleViewModel(titleName: selectedTitle?.original_title ?? "", posterURL: selectedTitle?.poster_path ?? ""))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
    }
    
    private func configureNavbar(){
        
        navigationController?.navigationBar.barTintColor = .systemBackground
        
        let logOutButton = createLogoutButton()
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.setImage(UIImage(named: "netflixLogo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        view.addSubview(button)
        
        let logo = UIBarButtonItem(customView: view)
        
        if userToken == nil {
            navigationItem.leftBarButtonItems = [logo]
            
        } else {
            navigationItem.leftBarButtonItems = [logo, logOutButton]
        }
        
        
        let label = setRightBarButtonItem()
        
        let view1 = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let button1 = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button1.setImage(UIImage(systemName: "play.rectangle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button1.titleLabel?.font = .systemFont(ofSize: 22)
        view1.addSubview(button1)
        
        let view2 = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let button2 = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button2.setImage(UIImage(systemName: "person")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button2.addTarget(self, action: #selector(userProfileButton), for: .touchUpInside)
        button2.titleLabel?.font = .systemFont(ofSize: 22)
        view2.addSubview(button2)
        
        let rectangle = UIBarButtonItem(customView: view1)
        let person = UIBarButtonItem(customView: view2)
        
        
        navigationItem.rightBarButtonItems = [ label, person, rectangle]
        
        navigationController?.navigationBar.tintColor = .label
    }
    
    func createLogoutButton() -> UIBarButtonItem {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
        button.setTitle("Log Out", for: .normal)
        //button.titleLabel?.textColor = .label
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(didLogOut), for: .touchUpInside)
        
        view.addSubview(button)
        
        return UIBarButtonItem(customView: view)
    }
    
    @objc func didLogOut() {
        
        spinner.show(in: view)
        
        let firebaseAuth = Auth.auth()
        
        do {
            
            try firebaseAuth.signOut()
            
        } catch {
            
            print(error.localizedDescription)
        }
        
        userToken = nil
        didLogIn = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            
            self.spinner.dismiss(animated: true)
            NotificationCenter.default.post(name: .didLogOut, object: nil)
        }
        
    }
    
    func createBarItem(imageName: String) -> UIBarButtonItem {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.setImage(UIImage(systemName: "\(imageName)")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        view.addSubview(button)
        
        return UIBarButtonItem(customView: view)
    }
    
    @objc func userProfileButton() {
        
        let nc = UINavigationController(rootViewController: LoginViewController())
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true)
        
    }
    
    func setRightBarButtonItem() -> UIBarButtonItem {
        
        if let user = Auth.auth().currentUser {
            
            self.userToken = user
        }
        
        var username = UserDefaults.standard.object(forKey: "name") as? String
        
        username = username?.components(separatedBy: " ").first
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        label.text = userToken == nil ? "Not Logged in": "Hello, \(username ?? "user")"
        view.addSubview(label)
        
        return UIBarButtonItem(customView: view)
    }
    
    func getCurrentUserToken() {
        
        handle = Auth.auth().addStateDidChangeListener({ [weak self] _, user in
            
            if let user = user {
                
                self?.userToken = user
                //self?.configureNavbar()
            }
            
        })
        
        if let user = Auth.auth().currentUser {
            self.userToken = user
        }
        
    }
    
    private func userStateListener() {
        
        NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main) { [weak self]_ in
            
            self?.didLogIn = true
            self?.configureNavbar()
            
        }
        
//        NotificationCenter.default.addObserver(forName: .didSignUp, object: nil, queue: .main) { [weak self]_ in
//
//
//            let nc = UINavigationController(rootViewController: LoginViewController())
//            self?.present(nc, animated: true)
//
//        }
        
        NotificationCenter.default.addObserver(forName: .didLogOut, object: nil, queue: .main) { [weak self] _ in
            
            self?.configureNavbar()
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CollectionViewTableViewCell.identifier, for: indexPath) as? CollectionViewTableViewCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        
        switch indexPath.section {
        case Section.TrendingMovies.rawValue:
            APICaller.shared.getTrendingMovies(){ result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error)
                }
            }
        case Section.TrendingTV.rawValue:
            APICaller.shared.getTrendingTVs(){ result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error)
                }
            }
        case Section.Popular.rawValue:
            APICaller.shared.getPopularMovies(){ result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error)
                }
            }
        case Section.Upcoming.rawValue:
            APICaller.shared.getUpcomingMovies(){ result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error)
                }
            }
        case Section.TopRated.rawValue:
            APICaller.shared.getTopRatedMovies(){ result in
                switch result {
                case .success(let titles):
                    cell.configure(with: titles)
                case .failure(let error):
                    print(error)
                }
            }
            
        default:
            return UITableViewCell()
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        header.textLabel?.frame = CGRect(x: header.bounds.origin.x - 20, y: header.bounds.origin.y , width: 100, height: header.bounds.height)
        header.textLabel?.textColor = .label
        header.textLabel?.text = header.textLabel?.text?.capitalized
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let defaultOffset = view.safeAreaInsets.top
        let offset = scrollView.contentOffset.y + defaultOffset
        
        navigationController?.navigationBar.transform = .init(translationX: 0, y: min(0,-offset))
    }
    
}

extension HomeViewController: CollectionViewTableViewCellDelegate {
    func CollectionViewTableViewCellDidTapCell(_cell: CollectionViewTableViewCell, viewModel: TitlePreviewViewModel) {
        
        DispatchQueue.main.async { [weak self] in
            
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
