import UIKit
import SnapKit

class TodayView: UIView {
    
    var data: ForecastResponse?
    private let weatherService = WeatherService(client: URLSessionHTTPClient())
    
    private let containerHours: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .white.withAlphaComponent(0.2)
        return view
    }()
    
    private let imageClock: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "clock"))
        imageView.tintColor = .white
        return imageView
    }()
    private let labelTodayHours: UILabel = {
        let label = UILabel()
        label.text = "hourly forecast".uppercased()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    let devider = UIView()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 55, height: 120)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12

        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.register(HourView.self,
                                forCellWithReuseIdentifier: HourView.identifier)
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.delegate = self
        collectionView.dataSource = self
        setupView()
    }
    
    func configure(data: ForecastResponse) {
        self.data = data
        self.collectionView.reloadData()
        DispatchQueue.main.async {
            print(self.collectionView.contentSize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(containerHours)
        
        containerHours.addSubview(imageClock)
        containerHours.addSubview(labelTodayHours)
        containerHours.addSubview(devider)
        containerHours.addSubview(collectionView)
        
        containerHours.snp.makeConstraints { make in
            make.top.equalToSuperview()//equalTo(labelMaxMin.snp.bottom).offset(CGFloat.adaptive(20, 40))
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(CGFloat.adaptive(20, 40))
            //make.height.equalTo(CGFloat.adaptive(200, 300))
            make.bottom.equalToSuperview()
        }
        
        imageClock.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.adaptive(10, 15))
            make.leading.equalToSuperview().offset(CGFloat.adaptive(14, 30))
            make.size.equalTo(CGFloat.adaptive(20, 40))
        }
        labelTodayHours.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.adaptive(10, 15))
            make.trailing.equalToSuperview().inset(CGFloat.adaptive(14, 30))
            make.leading.equalTo(imageClock.snp.trailing).offset(CGFloat.adaptive(14, 30))
        }
        devider.backgroundColor = .white.withAlphaComponent(0.1)
        devider.snp.makeConstraints { make in
            make.top.equalTo(labelTodayHours.snp.bottom).offset(CGFloat.adaptive(14, 30))
            make.height.equalTo(1)
            make.horizontalEdges.equalToSuperview().inset(CGFloat.adaptive(14, 30))
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(devider.snp.bottom).offset(CGFloat.adaptive(14, 30))
            make.bottom.equalToSuperview().inset(CGFloat.adaptive(14, 30))
            make.horizontalEdges.equalToSuperview().inset(CGFloat.adaptive(14, 30))
        }
    }
}

extension TodayView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getHoursData().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HourView.identifier,
            for: indexPath
        ) as! HourView
        cell.configure(
            hour: indexPath.row == 0 ? "Now" : String(getHoursData()[indexPath.row].time.suffix(5)),
            image: getHoursData()[indexPath.row].condition.icon,//"person",
            temperature: getHoursData()[indexPath.row].temp_c.description)
        return cell
    }
    
    func getHoursData() -> [Hour] {
      guard let result = data?.forecast.forecastday.first?.hour.filter({ filterHourNow(data: $0.time) }) else {
            return []
        }
        return result
    }
    
    func filterHourNow(data: String ) -> Bool {
        let format: String = "yyyy-MM-dd HH:mm"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        guard let date = formatter.date(from: data) else {
            return false
        }
        let calendar = Calendar.current
        guard calendar.isDateInToday(date) else {
            return false
        }
        let inputHour = calendar.component(.hour, from: date)
        let currentHour = calendar.component(.hour, from: Date())
        return inputHour >= currentHour
    }
}

class HourView: UICollectionViewCell {
    static let identifier = "HourView"
    private let hourLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "NOW"
        return label
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "99"
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "sun.max")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        //backgroundColor = .red.withAlphaComponent(0.3)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [hourLabel, imageView, temperatureLabel])
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.axis = .vertical
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.height.equalTo(CGFloat.adaptive(30, 60))
        }
    }
    
    func configure(hour: String, image: String, temperature: String) {
        hourLabel.text = hour
        imageView.loadImage(from: image)
        temperatureLabel.text = temperature
    }
}
