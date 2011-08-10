require 'spec_helper'

describe Travis::Notifications::Pusher do
  attr_reader :task, :build

  before do
    request = Factory(:request)
    @task   = request.task
    @build  = Factory(:build, :request => request)

    # TODO extract stup_pusher or something
    Travis.config.notifications = [:pusher]
    Travis::Notifications::Pusher.send(:public, :queue_for, :data_for, :template_dir)
    Travis::Notifications::Pusher.any_instance.stubs(:channel).returns(Support::Mocks::Pusher.new)
  end

  after do
    Travis.config.notifications.clear
    Travis::Notifications.subscriptions.clear
    Travis::Notifications::Pusher.send(:protected, :queue_for, :data_for, :template_dir)
  end

  let(:receiver) { Travis::Notifications::Pusher.new }

  describe 'data_for' do
    it 'returns the payload required for client side task events' do
      receiver.data_for('task:configure:created', task).keys.should == %w(build repository)
    end

    it 'returns the payload required for client side build events' do
      receiver.data_for('build:started', build).keys.should == %w(build repository)
    end
  end

  describe 'queue_for' do
    it 'returns "jobs" for task events' do
      receiver.queue_for('task:configure:created').should == 'jobs'
    end

    it 'returns "jobs" for build events' do
      receiver.queue_for('build:started').should == 'repositories'
    end
  end

  describe 'template_dir' do
    it 'returns "task_created" for task events' do
      receiver.template_dir('task:configure:created', task).should == 'task_created'
    end

    it 'returns "build_created" for build events' do
      receiver.template_dir('build:started', build).should == 'build_started'
    end
  end
end
