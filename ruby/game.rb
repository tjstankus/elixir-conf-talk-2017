require "forwardable"

module Bowling
  class Game
    attr_reader :frames

    def initialize
      @frames = Array.new(10) { Frame.new }
    end

    def roll(pinfall)
      frames_handling_roll.each { |f| f.roll(pinfall) }
    end

    def score
      frames.sum(&:score)
    end

    private

    def frames_handling_roll
      frame_handling_normal_roll + frames_handling_bonus_roll
    end

    def frame_handling_normal_roll
      Array(frames.detect(&:handles_normal_roll?)).compact
    end

    def frames_handling_bonus_roll
      frames.select(&:handles_bonus_roll?)
    end
  end

  class Frame
    extend Forwardable
    def_delegators :@state,
      :score,
      :handles_normal_roll?,
      :handles_bonus_roll?

    attr_reader :rolls
    attr_accessor :state

    def initialize
      @rolls = []
      @state = FrameState.initial_state(self)
    end

    def roll(pinfall)
      rolls << pinfall
      state.transition!
    end

    def strike?
      rolls.first == 10
    end

    def spare?
      !strike? && rolls.first(2).sum == 10
    end

    def bonus?
      strike? || spare?
    end

    def open?
      !strike? && !spare? && rolls_count == 2
    end

    def rolls_count
      rolls.length
    end
  end

  class FrameState
    def self.initial_state(frame)
      PendingState.new(frame)
    end

    attr_reader :frame

    def initialize(frame)
      @frame = frame
    end

    def transition!
      frame.state =
        [BonusState, CompleteState, PendingState].detect do |klass|
          klass.state_for?(frame)
        end.new(frame)
    end
  end

  class PendingState < FrameState
    def self.state_for?(frame)
      !frame.bonus? && !frame.open?
    end

    def score
      0
    end

    def handles_normal_roll?
      true
    end

    def handles_bonus_roll?
      false
    end
  end

  class BonusState < FrameState
    def self.state_for?(frame)
      frame.bonus? && frame.rolls_count < 3
    end

    def score
      0
    end

    def handles_normal_roll?
      false
    end

    def handles_bonus_roll?
      true
    end
  end

  class CompleteState < FrameState
    def self.state_for?(frame)
      (frame.bonus? && frame.rolls_count == 3) ||
        (frame.open? && frame.rolls_count == 2)
    end

    def score
      frame.rolls.sum
    end

    def handles_normal_roll?
      false
    end

    def handles_bonus_roll?
      false
    end
  end
end
