import UIKit
import SnapKit
import CoreLocation

class ViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let refreshControl = UIRefreshControl()
    
    
    private let gradientBg = CAGradientLayer()
    private var gradientTimer: Timer?
    
    private let locationManager = CLLocationManager()
    private let defaultLat = 68.9701//65.019//55.75   // Москва
    private let defaultLon = 33.0766//25.426//37.61
    private var curLat: Double = 0
    private var curLon: Double = 0
    
    private let weatherService = WeatherService(client: URLSessionHTTPClient())
    private var weatherEffectManager: WeatherEffectManager!
    
    private let effects: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let labelCity: UILabel = {
        let label = UILabel()
        label.text = "Unknown"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 37, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private let labelTemp: UILabel = {
        let label = UILabel()
        label.text = "-°"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 102, weight: .thin)
        label.textColor = .white
        return label
    }()
    
    private let labelType: UILabel = {
        let label = UILabel()
        label.text = "_"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private let labelMaxMin: UILabel = {
        let label = UILabel()
        label.text = "Max.:-°,min.:-°"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private let todayView = TodayView()
    private let tenDaysView = ThreeDaysView()
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientBg.frame = view.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherEffectManager = WeatherEffectManager(in: effects)
        setupLocation()
        startGradientTimer()
        updateGradientForCurrentTime()
        setupHierarchy()
        setupLayout()

        refreshData(lat: defaultLat, lon: defaultLon)
    }
    
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func updateGradientForCurrentTime() {

        let progress = dayProgress()

        let night = UIColor.black
        let sunrise = UIColor.systemOrange
        let day = UIColor.systemBlue
        let sunset = UIColor.systemPurple

        let color1: UIColor
        let color2: UIColor

        switch progress {

        case 0..<0.25: // ночь → рассвет
            let fraction = progress / 0.25
            color1 = night.interpolate(to: sunrise, fraction: fraction)
            color2 = UIColor.systemIndigo.interpolate(to: UIColor.systemPink, fraction: fraction)

        case 0.25..<0.5: // рассвет → день
            let fraction = (progress - 0.25) / 0.25
            color1 = sunrise.interpolate(to: day, fraction: fraction)
            color2 = UIColor.systemPink.interpolate(to: UIColor.systemTeal, fraction: fraction)

        case 0.5..<0.75: // день → закат
            let fraction = (progress - 0.5) / 0.25
            color1 = day.interpolate(to: sunset, fraction: fraction)
            color2 = UIColor.systemTeal.interpolate(to: UIColor.systemOrange, fraction: fraction)

        default: // закат → ночь
            let fraction = (progress - 0.75) / 0.25
            color1 = sunset.interpolate(to: night, fraction: fraction)
            color2 = UIColor.systemOrange.interpolate(to: UIColor.black, fraction: fraction)
        }

        animateGradient(to: [color1.cgColor, color2.cgColor])
    }
    
    private func animateGradient(to colors: [CGColor]) {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = gradientBg.colors
        animation.toValue = colors
        animation.duration = 1.0

        gradientBg.colors = colors
        gradientBg.add(animation, forKey: "colorChange")
    }
    
    private func startGradientTimer() {
        gradientTimer?.invalidate()
        gradientTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateGradientForCurrentTime()
        }
    }
    
    private func dayProgress() -> CGFloat {
        let now = Date()
        let calendar = Calendar.current

        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)

        let totalMinutes = hour * 60 + minute
        return CGFloat(totalMinutes) / CGFloat(24 * 60)
    }
    
    private func setupData(_ data: ForecastResponse) {
        DispatchQueue.main.async {
            self.labelCity.text = data.location.name
            self.labelType.text = data.current.condition.text
            self.labelTemp.text = "\(String(format: "%.1f", data.current.temp_c))°"

            let max = data.forecast.forecastday.first?.day.maxtemp_c
            let min = data.forecast.forecastday.first?.day.mintemp_c

            self.labelMaxMin.text = "Max.: \(max != nil ? "\(String(format: "%.1f", max!))" : "-")°, min.: \(min != nil ? "\(String(format: "%.1f", min!))" : "-")°"
        }
        weatherEffectManager.applyEffect(for: data.current.condition.code)
        todayView.configure(data: data)
        tenDaysView.configure(data: data)
    }
    
    private func refreshData(lat: Double, lon: Double) {
        Task {
            do {
                let response = try await weatherService.fetchForecast(lat: lat, lon: lon)
                await MainActor.run {
                    self.setupData(response)
                }
            } catch {
                await MainActor.run {
                    self.showErrorAlert(error: error)
                }
            }
        }
    }
    
    @objc private func refData(){
        self.refreshControl.beginRefreshing()
        //refreshData(lat: curLat, lon: curLon)
        self.refreshControl.endRefreshing()
    }
    
    func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Ошибка загрузки",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
    
    private func setupHierarchy() {
        view.layer.insertSublayer(gradientBg, at: 0)
        
        view.addSubview(effects)
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)

        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refData), for: .valueChanged)
        
        contentView.addSubview(labelCity)
        contentView.addSubview(labelTemp)
        contentView.addSubview(labelType)
        contentView.addSubview(labelMaxMin)
        contentView.addSubview(todayView)
        contentView.addSubview(tenDaysView)
    }
    
    private func setupLayout() {
        view.backgroundColor = .gray
        effects.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        refreshControl.tintColor = .white
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        labelCity.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.adaptive(50, 50))
            make.centerX.equalToSuperview()
        }
        labelTemp.snp.makeConstraints { make in
            make.top.equalTo(labelCity.snp.bottom)
            make.centerX.equalToSuperview()
        }
        labelType.snp.makeConstraints { make in
            make.top.equalTo(labelTemp.snp.bottom)
            make.centerX.equalToSuperview()
        }
        labelMaxMin.snp.makeConstraints { make in
            make.top.equalTo(labelType.snp.bottom)
            make.centerX.equalToSuperview()
        }
        todayView.snp.makeConstraints { make in
            make.top.equalTo(labelMaxMin.snp.bottom).offset(CGFloat.adaptive(20, 40))
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(CGFloat.adaptive(200, 300))
        }
        tenDaysView.snp.makeConstraints { make in
            make.top.equalTo(todayView.snp.bottom).offset(CGFloat.adaptive(20, 40))
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(CGFloat.adaptive(200, 300))
            make.bottom.equalToSuperview().offset(-CGFloat.adaptive(20, 40))
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            refreshData(lat: defaultLat, lon: defaultLon)
            return
        }
        curLat = location.coordinate.latitude
        curLon = location.coordinate.longitude
        refreshData(lat: curLat, lon: curLon)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        refreshData(lat: defaultLat, lon: defaultLon)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            refreshData(lat: defaultLat, lon: defaultLon)
        default:
            break
        }
    }
    
}

