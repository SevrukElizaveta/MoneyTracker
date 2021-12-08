//
//  Chart.swift
//  MoneyTracker
//
//  Created by Elizaveta Sevruk.
//

import SwiftUI

struct DataForPie: Identifiable {
    var id = UUID()
    let prev: ChartData?
    let next: ChartData
    let index: Int
}


struct ChartData: Identifiable {
    var id = UUID()
    var color : Color
    var percent : CGFloat
    var value : CGFloat
    var index: Int
}

class TransactionSumForCategory {
    let categoryName: String
    let color: UIColor
    var value: Float

    init(categoryName: String, value: Float, color: UIColor) {
        self.categoryName = categoryName
        self.value = value
        self.color = color
    }
}


struct Chart: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    var fetchRequest: FetchRequest<CardTransaction>

    init(card: Card) {
        fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [
            .init(key: "timestamp", ascending: false)
        ], predicate: .init(format: "card == %@", card))
    }

    @State var indexOfTappedSlice = -1
    var body: some View {
        NavigationView {
            VStack {
                //MARK:- Pie Slices
                ZStack {
                    ForEach(forPie()) { data in
                        Circle()
                            .trim(from: data.prev?.value ?? 0.0,
                                  to: data.next.value)
                            .stroke(data.next.color, lineWidth: 100)
                            .scaleEffect(data.index == indexOfTappedSlice ? 1.1 : 1.0)
//                            .animation(.spring())
                    }
                }.frame(width: 100, height: 200)

                //MARK:- Description
                ForEach(dataForChart()) { chartData in
                    HStack {
                        Text(String(format: "%.2f", Double(chartData.percent))+"%")
                            .onTapGesture {
                                indexOfTappedSlice = indexOfTappedSlice == chartData.index ? -1 : chartData.index
                            }
                            .font(indexOfTappedSlice == chartData.index ? .headline : .subheadline)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(chartData.color)
                            .frame(width: 15, height: 15)
                    }
                }
                .padding(8)
                .frame(width: 300, alignment: .trailing)
            }
            .navigationTitle("Chart")
            .navigationBarItems(leading: returnButton)
        }
    }

    private var returnButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        })
    }

    func dataForChart() -> [ChartData] {
        let arrayOfTransactionsSumForCategory = fetchRequest.wrappedValue.reduce([TransactionSumForCategory](), { partialResult, transaction in
            var additionalResult = [TransactionSumForCategory]()
            for category in (transaction.categories as? Set<TransactionCategory> ?? Set<TransactionCategory>()) {
                if let sum = partialResult.first(where: { $0.categoryName == category.name }) {
                    sum.value += transaction.amount
                } else {
                    additionalResult.append(
                        TransactionSumForCategory(
                            categoryName: category.name ?? "",
                            value: transaction.amount,
                            color: UIColor.color(data: category.colorData!)!
                        )
                    )
                }
            }

            return partialResult + additionalResult
        })
        .sorted { $0.value > $1.value }

        let allAmount = arrayOfTransactionsSumForCategory.reduce(0) { partialResult, sum in
            return partialResult + sum.value
        }

        var percentCount = 0.0
        return arrayOfTransactionsSumForCategory.enumerated().map { index, sum in
            let percent = CGFloat(sum.value / allAmount)
            percentCount += percent
            return ChartData(color: Color(sum.color), percent: percent * 100, value: percentCount > 1.0 ? 1.0 : percentCount, index: index)
        }
    }

    func forPie() -> [DataForPie] {
        let op: ChartData? = nil
        let data = dataForChart()
        guard let firstValue = dataForChart().first else { return [] }
        let first = [(op, firstValue)]
        let second = Array(zip(data.map { Optional($0) }, data.dropFirst()))
        let sum = first + second
        let result = sum.enumerated().map { DataForPie(id: $0.1.1.id, prev: $0.1.0, next: $0.1.1, index: $0.0) }
        print(result)
        return result
    }
}
