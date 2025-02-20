class SlaSchedularWorker
  include Sidekiq::Worker

  def perform
    SlaSchedule.create
  end
end
