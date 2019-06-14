//
//  SeatMapSelectionViewController.swift
//  Shinkansen Tickets Booking Prototype
//
//  Created by Virakri Jinangkul on 5/14/19.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit

class SeatMapSelectionViewController: BookingViewController {
    
    var mainCardView: CardControl!
    
    var seatMapSceneView: SeatMapSceneView!
    
    var selectedSeatID: Int?
    
    var seatClass: SeatClass?
    
    var seatClassEntities: [SeatClassEntity] = []
    
    var seatClassEntity: SeatClassEntity?
    
    private var isTransitionPerforming: Bool = true
    
    private var selectedEntity: ReservableEntity? {
        didSet {
            
           
           if headerInformation?.carNumber != selectedEntity?.carNumber {
           headerInformation?.carNumber = selectedEntity?.carNumber
            headerRouteInformationView.descriptionSetView.carNumberSetView.alpha = 0
            }
            
            mainCallToActionButton.isEnabled = selectedEntity != nil
            mainCallToActionButton.setTitle("Pick a Seat—\(selectedEntity?.name ?? "*")")
            mainCallToActionButton.titleLabel?.alpha = 0
            
            UIView.animate(withDuration: 0.35,
                           animations: {
                            self.headerRouteInformationView
                                .descriptionSetView
                                .carNumberSetView.alpha = 1
                            self.mainCallToActionButton
                                .titleLabel?.alpha = 1
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStaticContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isTransitionPerforming = false
    }
    
    override func setupView() {
        super.setupView()
        mainViewType = .view
        
        mainCardView = CardControl(type: .large)
        mainContentView.addSubview(mainCardView,
                                   withConstaintEquals: .edges,
                                   insetsConstant: .init(bottom: -mainCardView.layer.cornerRadius))
        
        seatMapSceneView = SeatMapSceneView()
        seatMapSceneView.seatMapDelegate = self
        mainCardView.contentView.addSubview(seatMapSceneView,
                                            withConstaintEquals: .edges)
        
        mainCardView.contentView.isUserInteractionEnabled = true
        mainCallToActionButton.isEnabled = false
        setupScene()
    }
    
    override func setupInteraction() {
        super.setupInteraction()
        
        mainCallToActionButton.addTarget(self,
                                         action: #selector(mainCallToActionButtonDidTouch(_:)),
                                         for: .touchUpInside)
        
        backButton.addTarget(self,
                             action: #selector(backButtonDidTouch(_:)),
                             for: .touchUpInside)
    }
    
    private func setupStaticContent() {
        mainCallToActionButton.setTitle("Pick a Seat")
    }
    
    private func setupScene() {
        print(seatClassEntity?.reservableEntities.count ?? 0)
        seatClassEntities.forEach {
            seatMapSceneView.setupContent(seatClassEntity: $0, isCurrentEntity: $0.name == seatClassEntity?.name)
        }
    }
    
    func verticalRubberBandEffect(byVerticalContentOffset contentOffsetY: CGFloat)  {
        guard contentOffsetY < 0 else {
            mainCardView.transform.ty = 0
            headerRouteInformationView.verticalRubberBandEffect(byVerticalContentOffset: 0)
            backButton.shapeView.transform.tx = 0
            return
        }
        mainCardView.transform.ty = -contentOffsetY
        
        headerRouteInformationView.verticalRubberBandEffect(byVerticalContentOffset: contentOffsetY)
    }
    
    @objc func mainCallToActionButtonDidTouch(_ sender: Button) {
        
        guard let selectedEntity = selectedEntity else {
            return
        }
        isTransitionPerforming = true
        
        let bookingConfirmationVC = BookingConfirmationViewController()
        bookingConfirmationVC.headerInformation = headerInformation
        bookingConfirmationVC.headerInformation?.seatNumber = selectedEntity.name
        bookingConfirmationVC.headerInformation?.price = seatClass?.price.yen
        navigationController?.pushViewController(bookingConfirmationVC, animated: true)
    }
    
    @objc func backButtonDidTouch(_ sender: Button) {
        isTransitionPerforming = true
        
        navigationController?.popViewController(animated: true)
    }
}

extension SeatMapSelectionViewController: SeatMapSceneViewDelegate {
    
    func sceneViewDidPanFurtherUpperBoundLimit(by offset: CGPoint) {
        
        if !isPopPerforming {
            
            // Perform interaction
            if !isTransitionPerforming {
                DispatchQueue.main.async {
                    self.verticalRubberBandEffect(byVerticalContentOffset: offset.y)
                }
            }
        }
    }
    
    func sceneView(sceneView: SeatMapSceneView, didSelected reservableEntity: ReservableEntity) {
        selectedEntity = reservableEntity
    }
}
