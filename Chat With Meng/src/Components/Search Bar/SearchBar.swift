import UIKit
import SwiftUI


struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var alwaysShowCancel: Bool = false
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
            searchBar.endEditing(true)
            searchBar.showsCancelButton = false
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
        searchBar.showsCancelButton = self.alwaysShowCancel
        return searchBar
    }
    
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
