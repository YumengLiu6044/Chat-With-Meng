import UIKit
import SwiftUI


struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var onCancelAction: (() -> Void)?
    var onSearchAction: (() -> Void)?
    

    class Coordinator: NSObject, UISearchBarDelegate {

        @Binding var text: String
        
        private var onCancelAction: (() -> Void)?
        private var onSearchAction: (() -> Void)?

        init(text: Binding<String>, cancelAction: (() -> Void)?, onSearchAction: (() -> Void)?) {
            _text = text
            self.onCancelAction = cancelAction
            self.onSearchAction = onSearchAction
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = true
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = nil
            searchBar.showsCancelButton = false
            
            searchBar.endEditing(true)
            
            self.onCancelAction?()
            
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            self.onSearchAction?()
        }
        
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, cancelAction: onCancelAction, onSearchAction: onSearchAction)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }
    
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}


extension SearchBar {
    func onCancelButtonPress(_ action: @escaping () -> Void) -> some View {
        var modifiedSearchBar = self
        modifiedSearchBar.onCancelAction = action
        return modifiedSearchBar
    }
    
    func onSearchButtonPress(_ action: @escaping () -> Void) -> some View {
        var modifiedSearchBar = self
        modifiedSearchBar.onSearchAction = action
        return modifiedSearchBar
    }
}
