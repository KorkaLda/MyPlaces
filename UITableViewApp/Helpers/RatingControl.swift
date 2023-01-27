//
//  RatingControl.swift
//  UITableViewApp
//
//  Created by Vladimir on 23.01.2023.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {

    private var ratingButtons = [UIButton]()
    var rating = 0{
        didSet{
            updateButtonSelectionState()
        }
    }

    
    @IBInspectable var starSize: CGSize = CGSize(width: 64, height: 64){
        didSet{
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    //MARK: - Инициализация
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    //MARK: - Button action
    
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else {return}
        //calculate rating of the selected button
        let selectedRating = index + 1
        if selectedRating == rating{
            rating = 0
        }else{
            rating = selectedRating
        }
    }
    
    //MARK: - Приватные методы
    private func setupButtons(){
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        //load button image
        let filledStar = UIImage(systemName: "star.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        let emptyStar = UIImage(systemName: "star")?.withTintColor(.systemPink, renderingMode: .alwaysOriginal)
        let highlightedStar = UIImage(systemName: "star.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        
        
        for _ in 0..<starCount {
            let button = UIButton()

            //set the button images
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])

            // Добаляем констрейнты
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            //Добавить action
            button.addTarget(self, action: #selector(ratingButtonTapped), for: .touchUpInside)
            
            
            //Добавить на стак вью
            addArrangedSubview(button)
            
            //Добавить новую кнопку в массив
            ratingButtons.append(button)
        }
        
        updateButtonSelectionState()
        
    }
    
    private func updateButtonSelectionState(){
        for (index, button) in ratingButtons.enumerated(){
            button.isSelected = index < rating
        }
    }

}
