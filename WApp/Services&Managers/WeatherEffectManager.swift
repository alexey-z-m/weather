import UIKit

final class WeatherEffectManager {

    private weak var view: UIView?
    private var activeEmitter: CAEmitterLayer?
    private var lightningTimer: Timer?
    private var fogView: UIView?

    init(in view: UIView) {
        self.view = view
    }

    // MARK: - Public

    func applyEffect(for code: Int) {
        removeEffects()

        switch effectType(for: code) {

        case .clear:
            break

        case .cloudy:
            addCloudOverlay()

        case .rain:
            addRain(intensity: 80)

        case .heavyRain:
            addRain(intensity: 160)

        case .snow:
            addSnow(intensity: 20)

        case .heavySnow:
            addSnow(intensity: 40)

        case .fog:
            addFog()

        case .thunder:
            addRain(intensity: 120)
            startLightning()
        }
    }

    func removeEffects() {
        activeEmitter?.removeFromSuperlayer()
        activeEmitter = nil

        lightningTimer?.invalidate()
        lightningTimer = nil

        fogView?.removeFromSuperview()
        fogView = nil
    }
}

// MARK: - Effect Types

private extension WeatherEffectManager {

    enum WeatherEffect {
        case clear
        case cloudy
        case rain
        case heavyRain
        case snow
        case heavySnow
        case fog
        case thunder
    }

    func effectType(for code: Int) -> WeatherEffect {
        switch code {

        case 1000:
            return .clear

        case 1003, 1006, 1009:
            return .cloudy

        case 1030, 1135, 1147:
            return .fog

        case 1063, 1150, 1153, 1180, 1183, 1186, 1189, 1240:
            return .rain

        case 1192, 1195, 1243, 1246:
            return .heavyRain

        case 1066, 1210, 1213, 1216, 1219:
            return .snow

        case 1222, 1225, 1255, 1258:
            return .heavySnow

        case 1087, 1273, 1276:
            return .thunder

        default:
            return .cloudy
        }
    }
}

// MARK: - Rain

private extension WeatherEffectManager {

    func addRain(intensity: Float) {
        guard let view else { return }

        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -10)
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        emitter.emitterShape = .line

        let cell = CAEmitterCell()
        cell.birthRate = intensity
        cell.lifetime = 4
        cell.velocity = 500
        cell.velocityRange = 100
        cell.scale = 0.15
        cell.emissionLongitude = .pi
        cell.color = UIColor.white.withAlphaComponent(0.6).cgColor
        cell.contents = makeRainDrop()

        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)

        activeEmitter = emitter
    }

    func makeRainDrop() -> CGImage? {
        let size = CGSize(width: 2, height: 12)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.setFill()
        UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 1).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.cgImage
    }
}

// MARK: - Snow

private extension WeatherEffectManager {

    func addSnow(intensity: Float) {
        guard let view else { return }

        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -10)
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        emitter.emitterShape = .line

        let cell = CAEmitterCell()
        cell.birthRate = intensity
        cell.lifetime = 12
        cell.velocity = 60
        cell.velocityRange = 40
        cell.scale = 0.3
        cell.emissionLongitude = .pi
        cell.color = UIColor.white.withAlphaComponent(0.3).cgColor
        cell.contents = makeSnowflake()

        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)

        activeEmitter = emitter
    }

    func makeSnowflake() -> CGImage? {
        // 1. Получаем SF Symbol
        let symbol = UIImage(systemName: "snow")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        
        // 2. Создаем context того же размера
        let size = CGSize(width: 10, height: 10) // подбираем размер
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // 3. Рисуем UIImage в context
        symbol?.draw(in: CGRect(origin: .zero, size: size))
        
        // 4. Получаем CGImage
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.cgImage
    }
//    func makeSnowflake() -> CGImage? {
//        let size = CGSize(width: 8, height: 8)
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        UIColor.white.setFill()
//        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image?.cgImage
//    }
}

// MARK: - Fog

private extension WeatherEffectManager {

    func addFog() {
        guard let view else { return }

        let fog = UIView(frame: view.bounds)
        fog.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        view.addSubview(fog)

        fogView = fog
    }

    func addCloudOverlay() {
        guard let view else { return }

        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        view.addSubview(overlay)

        fogView = overlay
    }
}

// MARK: - Thunder

private extension WeatherEffectManager {

    func startLightning() {
        lightningTimer = Timer.scheduledTimer(withTimeInterval: 5,
                                              repeats: true) { [weak self] _ in
            self?.flash()
        }
    }

    func flash() {
        guard let view else { return }

        let flash = UIView(frame: view.bounds)
        flash.backgroundColor = .white
        flash.alpha = 0
        view.addSubview(flash)

        UIView.animate(withDuration: 0.1, animations: {
            flash.alpha = 0.9
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                flash.alpha = 0
            } completion: { _ in
                flash.removeFromSuperview()
            }
        }
    }
}
