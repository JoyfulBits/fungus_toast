defmodule FungusToast.Game.Status do
  @status_not_started "Not Started"
  def status_not_started, do: @status_not_started

  @status_started "Started"
  def status_started, do: @status_started

  @status_finished "Finished"
  def status_finished, do: @status_finished

  @status_abandoned "Abandoned"
  def status_abandoned, do: @status_abandoned

  @status_archived "Archived"
  def status_archived, do: @status_archived

  @statuses [@status_not_started, @status_started, @status_finished, @status_abandoned, @status_archived]
  def statuses, do: @statuses

  @active_statuses [@status_not_started, @status_started]
  def active_statuses, do: @active_statuses
end
