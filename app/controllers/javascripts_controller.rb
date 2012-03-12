class JavascriptsController < ApplicationController
  def timeslice_totals_by_day
    unless params[:start].blank? && params[:end].blank?
      @timeslices = Timeslice.by_date(Time.at(params[:start].to_i), Time.at(params[:end].to_i)).find_all {|t| t.chargeable};
    else
      @timeslices = Timeslice.find(:all).find_all {|t| t.chargeable}
    end

    respond_to do |format|
      format.js do
        timeslice_collection = @timeslices.group_by(&:week).collect do |w, timeslices|
          {
          'id' => 'w-' + w.to_s,
          'title' => (Timeslice.total_duration(timeslices)/60/60).round(2).to_s + ' hour(s)',
          'start' => timeslices[0].date.beginning_of_week.xmlschema,
          'end' => timeslices[0].date.end_of_week.xmlschema,
          'className' => 'week-total-time'
          }
        end
        timeslice_collection += @timeslices.group_by(&:date).collect do |d, timeslices|
          {
          'id' => d,
          'title' => (Timeslice.total_duration(timeslices)/60/60).round(2).to_s + ' hour(s)',
          'start' => timeslices[0].date.beginning_of_day.xmlschema,
          'end' => timeslices[0].date.end_of_day.xmlschema,
          'className' => 'day-total-time'
          }
        end
        render :json => timeslice_collection
      end
    end
  end
end
