import UIKit
import SnapKit

class ThreeDaysView: UIView {
    var data: ForecastResponse?
    var daysData: [ForecastDay] = []
    private let weatherService = WeatherService(client: URLSessionHTTPClient())
    
    private let containerHours: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .white.withAlphaComponent(0.2)
        return view
    }()
    
    private let imageClock: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "calendar"))
        imageView.tintColor = .white
        return imageView
    }()
    private let labelTodayHours: UILabel = {
        let label = UILabel()
        label.text = "3-day forecast".uppercased()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    let devider = UIView()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 320, height: 40)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12

        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.register(DaysView.self,
                                forCellWithReuseIdentifier: DaysView.identifier)
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.delegate = self
        collectionView.dataSource = self
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(data: ForecastResponse) {
        self.data = data
        self.collectionView.reloadData()
        daysData = getDaysData()
        DispatchQueue.main.async {
            print(self.collectionView.contentSize)
        }
    }
    
    private func setupView() {
        addSubview(containerHours)
        containerHours.addSubview(imageClock)
        containerHours.addSubview(labelTodayHours)
        containerHours.addSubview(devider)
        containerHours.addSubview(collectionView)
        containerHours.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(CGFloat.adaptive(20, 40))
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
    
    func getDaysData() -> [ForecastDay] {
        guard let result = data?.forecast.forecastday else {
            return []
        }
        return result
    }
}

extension ThreeDaysView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(daysData.count)
        return daysData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DaysView.identifier,
            for: indexPath
        ) as! DaysView
        cell.configure(
            day: indexPath.row == 0 ? "Today" : getWeekday(from: String(daysData[indexPath.row].date)) ?? "-",
            image: daysData[indexPath.row].day.condition.icon,
            temperature: daysData[indexPath.row].day.mintemp_c.description + " / " + daysData[indexPath.row].day .maxtemp_c.description)
        return cell
    }
    
    func getWeekday(from dateString: String) -> String? {
        // Формат вашей даты (пример: "2024-01-15" или "2024-01-15 12:00")
        let inputFormat = "yyyy-MM-dd" // Измените под ваш формат
        
        let formatter = DateFormatter()
        formatter.dateFormat = inputFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        
        guard let date = formatter.date(from: dateString) else {
            return nil
        }
        
        // Получаем день недели на английском
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE" // Полное название (Monday)
        // weekdayFormatter.dateFormat = "EEE" // Сокращенное (Mon)
        weekdayFormatter.locale = Locale(identifier: "en_US") // Английский язык
        
        return weekdayFormatter.string(from: date)
    }
    
}

class DaysView: UICollectionViewCell {
    static let identifier = "DaysView"
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Today"
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
        let stack = UIStackView(arrangedSubviews: [dayLabel, imageView, temperatureLabel])
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.axis = .horizontal
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(CGFloat.adaptive(40, 80))
        }
    }
    
    func configure(day: String, image: String, temperature: String) {
        dayLabel.text = day
        imageView.loadImage(from: image)
        temperatureLabel.text = temperature
    }
}
