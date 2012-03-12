class TimeslicePresenter < BasePresenter
  presents :timeslice
  delegate :description, :date, :started_time, :finished_time, :chargeable, :to => :timeslice

  def time
    "#{timeslice.started_time} - #{timeslice.finished_time}"
  end

  def duration
     distance_of_time_in_words(timeslice.started, timeslice.finished, true);
  end
end
