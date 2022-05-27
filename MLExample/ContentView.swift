import SwiftUI
import CoreML

struct ContentView: View {

    let model: MobileNetV2 = {
        let config = MLModelConfiguration()
        let model = try! MobileNetV2(configuration: config)
        return model
    }()
    
    @State var classLabel: String = ""
    @State var classLabelProbs: [(String, Double)] = []
    @State var selectedImage: UIImage?
    @State var showImagePicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 200)
                            .cornerRadius(5)
                    }
                    else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                            .frame(width: 280, height: 185)
                    }
                }
                .padding(.top, 30)
                
                Text(classLabel)
                    .font(.title)
                    .padding()
                
                List {
                    ForEach(classLabelProbs, id: \.0) { result in
                        HStack {
                            Text(result.0)
                            Spacer()
                            Text(String(format: "%.2f%%", result.1 * 100))
                        }
                    }
                }
                .listStyle(.plain)
                
                Spacer()
            }
            .sheet(isPresented: $showImagePicker, onDismiss: {
                predict(image: selectedImage)
            }, content: {
                ImagePicker(sourceType: .library, selectedImage: $selectedImage)
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Load Image") {
                        showImagePicker = true
                    }
                }
            }
            .navigationTitle("ML Example")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func predict(image: UIImage?) {
        guard let image = image,
              let resizedImage = image.resizeTo(size: CGSize(width: 224, height: 224)),
              let buffer = resizedImage.toBuffer() else {
            return
        }
        
        if let result = try? model.prediction(image: buffer) {
            classLabel = result.classLabel
            classLabelProbs = Array(result.classLabelProbs.sorted {
                $0.1 > $1.1
            }.prefix(10))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
