require 'glimmer-dsl-libui'
require_relative 'pmv_calc'

class FormTable
  include Glimmer

  Inputs = %i[clo met wme ta tr vel rh]
  Result = Struct.new(*Inputs, :pmv, :ppd)

  # inputs
  attr_accessor *Inputs

  # results
  attr_reader :results

  def initialize
    @entries = {
      clo: 'clothing',
      met: 'metabolic rate',
      wme: 'external work',
      ta: 'air temperature (°c)',
      tr: 'mean radiant temperature (°c)',
      vel: 'relative air velocity (m/s)',
      rh: 'relative humidity (%)'
    }
    @results = []
    @wme, @ta, @tr, @vel, @rh, @met, @clo = [0, 22.0, 22.0, 0.10, 60, 1.2, 0.5].map(&:to_s)
  end

  def calculate(entries)
    PMVCalc.new.calc(*entries)
  end

  def launch
    window('PMV Calc', 600, 600) do
      margined true

      vertical_box do
        form do
          stretchy false
          @entries.each do |var, description|
            entry do
              label(description)
            text <=> [self, var] # bidirectional data-binding between entry text and self.name
            end
          end
        end

        button('Calculate') do
          stretchy false

          on_clicked do
            new_row = Inputs.map { |i| send(i) }.map(&:to_f)
            if new_row.map(&:to_s).include?('')
              msg_box_error('Validation Error!', 'All fields are required! Please make sure to enter a value for all fields.')
            else
              @pmv, @ppd = calculate(new_row).map(&:to_s)
              @results << Result.new(*new_row, @pmv, @ppd) # automatically inserts a row into the table due to explicit data-binding
              Inputs.zip(new_row).map { |input, value| send("#{input}=", value.to_s) }
            end
         end
        end

      # vertical_box do
      #    form do
      #     stretchy false

     #      entry do
      #        label('PMV')
     #        text <=> [self, :pmv] # bidirectional data-binding between entry text and self.name
      #     end

      #     entry do
      #       label('PPD')
     #        text <=> [self, :ppd] # bidirectional data-binding between entry text and self.name
      #     end
      #    end
      #  end
      # search_entry do
       #   stretchy false
       #  # bidirectional data-binding of text to self.filter_value with after_write option
       #   text <=> [self, :filter_value,
       #             after_write: lambda { |filter_value| # execute after write to self.filter_value
       #               @unfiltered_contacts ||= @contacts.dup
       #               # Unfilter first to remove any previous filters
       #               self.contacts = @unfiltered_contacts.dup # affects table indirectly through explicit data-binding
       #               # Now, apply filter if entered
       #               unless filter_value.empty?
       #                 self.contacts = @contacts.filter do |contact| # affects table indirectly through explicit data-binding
       #                   contact.members.any? do |attribute|
       #                     contact[attribute].to_s.downcase.include?(filter_value.downcase)
       #                   end
       #                 end
       #               end
       #             }]
      # end

        table do
          @entries.each do |var, _description|
            text_column(var.to_s)
          end
          text_column('PMV')
          text_column('PPD')

          cell_rows <=> [self, :results] # explicit data-binding to self.contacts Modal Array, auto-inferring model attribute names from underscored table column names by convention

          #  on_changed do |row, type, row_data|
          #    puts "Row #{row} #{type}: #{row_data}"
          #    $stdout.flush # for Windows
          #  end

          #  on_edited do |row, row_data| # only fires on direct table editing
          #    puts "Row #{row} edited: #{row_data}"
          #    $stdout.flush # for Windows
            #   end
        end
      end
    end.show
  end
end

FormTable.new.launch
