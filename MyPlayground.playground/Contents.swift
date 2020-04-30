import Foundation

class VendingMachineProduct: Equatable {
    var name: String
    var amount: Int
    var price: Double

    init(name: String, amount: Int, price: Double) {
        self.name = name
        self.amount = amount
        self.price = price
    }

    static func ==(lhs: VendingMachineProduct, rhs: VendingMachineProduct) -> Bool {
        return lhs.name == rhs.name
    }
}

enum VendingMachineError: Error {
    case productNotFound
    case productUnavailable
    case productStuck
    case wrongProduct(product: VendingMachineProduct)
    case insufficientFunds
}

extension VendingMachineError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Desculpe, mas esse item está em outra vending machine"
        case .productUnavailable:
            return "Temos um total de zero unidades disso aqui..."
        case .productStuck:
            return "Tenho uma má notícia pra você... Travou essa porcaria"
        case .wrongProduct(let product):
            return "Ihhh rapaz, caiu o produto errado! Você acabou ganhando um(a) \(product.name)"
        case .insufficientFunds:
            return "Tá me zoando? Coloca o dinheiro necessário aí..."
        }
    }
}

class VendingMachine {
    private var estoque: [VendingMachineProduct]
    private var money: Double

    init(products: [VendingMachineProduct]) {
        self.estoque = products
        self.money = 0
    }

    func getProduct(named name: String, with money: Double) throws {
        self.money += money

        let optionalProduct = estoque.first { $0.name == name }
        guard let product = optionalProduct else { throw VendingMachineError.productNotFound }

        guard product.amount > 0 else { throw VendingMachineError.productUnavailable }

        guard product.price <= self.money else { throw VendingMachineError.insufficientFunds }

        self.money -= product.price
        product.amount -= 1

        let odds = Int.random(in: 0...100)
        if odds < 10 {
            throw VendingMachineError.productStuck
        } else if odds >= 10 && odds < 14 {
            if let randomProduct = estoque.filter({ $0 != product && $0.amount > 0 }).randomElement() {
                product.amount += 1
                randomProduct.amount -= 1
                throw VendingMachineError.wrongProduct(product: randomProduct)
            }
        }
    }

    func getTroco() -> Double {
        let money = self.money
        self.money = 0.0

        return money
    }
}

let vendingMachine = VendingMachine(products: [
    VendingMachineProduct(name: "Carregador iPhone", amount: 5, price: 150.00),
    VendingMachineProduct(name: "Funnions", amount: 2, price: 7.00),
    VendingMachineProduct(name: "Xiaomi Umbrella", amount: 5, price: 125.00),
    VendingMachineProduct(name: "Tractor", amount: 1, price: 75000.0)
])

do {
    try vendingMachine.getProduct(named: "Xiaomi Umbrella", with: 2000.0)
    try vendingMachine.getProduct(named: "Funnions", with: 0.0)
    try vendingMachine.getProduct(named: "Carregador iPhone", with: 0.0)

    print("Boa, conseguiu comprar tudo!")
} catch {
    print(error.localizedDescription)
}
