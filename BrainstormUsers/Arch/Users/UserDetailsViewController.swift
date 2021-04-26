//
//  UserDetailsViewController.swift
//  BrainstormUsers
//
//  Created by Hovak Davtyan on 24.04.21.
//

import MapKit
import UIKit

// MARK: - UserDetailsViewControllerDelegate

protocol UserDetailsViewControllerDelegate: AnyObject {
    func didAdd(_ user: User)
    func didDelete(_ user: User)
}

extension UserDetailsViewControllerDelegate {
    func didAdd(_user: User) {}
    func didDelete(_user: User) {}
}

// MARK: - UserDetailsViewController

final class UserDetailsViewController: UIViewController {
    // MARK: - Dependencies

    var user: User!
    weak var delegate: UserDetailsViewControllerDelegate?
    var isLocal: Bool! {
        didSet {
            saveButton?.isEnabled = !isLocal
            removeButton?.alpha = isLocal ? 1 : 0
        }
    }

    // MARK: - Outlets

    @IBOutlet private var mapView: MKMapView! {
        didSet { mapView.delegate = self }
    }

    @IBOutlet private var avatarImageView: UIImageView! {
        didSet { configureAvatarImageView() }
    }

    private func configureAvatarImageView() {
        avatarImageView.cornerRadius = avatarImageView.bounds.height / 2
        avatarImageView.layer.borderWidth = 3
        avatarImageView.layer.borderColor = UIColor.systemBackground.cgColor
    }

    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var countryLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var saveButton: GradientButton! {
        didSet {
            saveButton.cornerRadius = saveButton.bounds.height / 2
            saveButton.isEnabled = !isLocal
        }
    }

    @IBOutlet private var removeButton: UIButton! {
        didSet { removeButton.alpha = isLocal ? 1 : 0 }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
    }

    // MARK: - View Config

    private func configureViews() {
        title = user.fullName
        configureMap()
        avatarImageView.kf.setImage(with: user.avatar)
        nameLabel.text = user.fullName
        infoLabel.text = user.info
        countryLabel.text = user.country
        addressLabel.text = user.address
    }

    private func configureMap() {
        let coordinate = CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100))
        mapView.setRegion(region, animated: false)
    }

    // MARK: - Actions

    @IBAction private func saveButtonTapped(_ sender: UIButton) {
        do {
            try UsersService.shared.save(user: user)
            isLocal = true
            delegate?.didAdd(user)
        } catch let error as AlertableError {
            showErrorAlert(error: error)
        } catch {
            print(error)
        }
    }

    @IBAction private func deleteButtonTapped(_ sender: UIButton) {
        do {
            try UsersService.shared.delete(user: user)
            delegate?.didDelete(user)
            navigationController?.popViewController(animated: true)
        } catch let error as AlertableError {
            showErrorAlert(error: error)
        } catch {
            print(error)
        }
    }
}

// MARK: MKMapViewDelegate

extension UserDetailsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "mapMarkerAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.image = UIImage(named: "mapMarker")
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
}
