//
//  CalendarViewController.swift
//  StrongFuture
//
//  Created by Rustem Orazbayev on 2/25/23.
//

import UIKit
import CalendarKit
import EventKit
import EventKitUI

class CalendarViewController: DayViewController, EKEventEditViewDelegate {
    private let eventStore = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Schedule"
        requestAccessToCalendar()
        subcribeToNotifications()

    }

    //requesting access from user for events
    func requestAccessToCalendar(){
        eventStore.requestAccess(to: .event) { success, error in

        }
    }

    //getting notified when new events appear
    func subcribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: .EKEventStoreChanged, object: nil)
    }

    //reloading calendar when new events appear
    @objc func storeChanged(_ notification: Notification){
        DispatchQueue.main.async {
            self.reloadData()
        }
    }

    //fetching events from calendar
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1

        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate)!

        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)

        //fetching from calendar
        let eventKitEvents = eventStore.events(matching: predicate)

        // converting eventKitEvents of type EKEvent to CalendarKit's format
        let calendarKitEvents = eventKitEvents.map(EKWrapper.init)
        return calendarKitEvents
    }

    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? EKWrapper else {
            return
        }


        //detail view
        let ekEvent = ckEvent.ekEvent
        presentDetailView(ekEvent)
    }

    private func presentDetailView(_ ekEvent: EKEvent) {
        //View from CalendarKit
        let eventViewController = EKEventViewController()
        eventViewController.event = ekEvent
        eventViewController.allowsCalendarPreview = true
        eventViewController.allowsEditing = true
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    //making events editing by long press, entering editing mode
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        endEventEditing()
        guard let ckEvent = eventView.descriptor as? EKWrapper else {
            return
        }

        beginEditing(event: ckEvent, animated: true)
    }

    // making possible to move events on calendar
    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        guard let editingEvent = event as? EKWrapper else { return }
        if let originalEvent = event.editedEvent {
            editingEvent.commitEditing()

            if originalEvent === editingEvent {
                //Event creation flow
                presentEditingViewForEvent(editingEvent.ekEvent)
            }else{
                //Editing flow
                try! eventStore.save(editingEvent.ekEvent, span: .thisEvent)
            }

        }
        self.reloadData()
    }

    func presentEditingViewForEvent(_ ekEvent: EKEvent) {
        let editingViewController = EKEventEditViewController()
        editingViewController.editViewDelegate = self
        editingViewController.event = ekEvent
        editingViewController.eventStore = eventStore
        present(editingViewController, animated: true, completion: nil)

    }

    //exiting editing mode
    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
    }

    //exiting editing mode
    override func dayViewDidBeginDragging(dayView: DayView) {
        endEventEditing()
    }

    //creating new event
    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        let newEKEvent = EKEvent(eventStore: eventStore)
        newEKEvent.calendar = eventStore.defaultCalendarForNewEvents

        var oneHourComponents = DateComponents()
        oneHourComponents.hour = 1
        let endDate = calendar.date(byAdding: oneHourComponents, to: date)

        newEKEvent.startDate = date
        newEKEvent.endDate = endDate
        newEKEvent.title = "New Event"

        let newEKWrapper = EKWrapper(eventKitEvent: newEKEvent)
        newEKWrapper.editedEvent = newEKWrapper

        create(event: newEKWrapper, animated: true)
    }


    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        endEventEditing()
        self.reloadData()
        controller.dismiss(animated: true, completion: nil)
    }
}
