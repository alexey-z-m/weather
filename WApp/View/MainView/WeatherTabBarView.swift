import UIKit

final class WeatherTabBarView: UIView {
    
    let mapButton = UIButton(type: .system)
    let pageControl = UIPageControl()
    let citiesButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        mapButton.setImage(UIImage(systemName: "map"), for: .normal)
        mapButton.tintColor = .white
        
        pageControl.numberOfPages = 5
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.isUserInteractionEnabled = false
        pageControl.backgroundColor = .red.withAlphaComponent(0.3)
        
        citiesButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        citiesButton.tintColor = .white
        
        let stack = UIStackView(arrangedSubviews: [mapButton, pageControl, citiesButton])
        
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            heightAnchor.constraint(equalToConstant: .adaptive(78, 78))
        ])
    }
}
