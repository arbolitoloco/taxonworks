namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'

      namespace :specimens do


        desc 'time rake tw:project_import:sf_import:specimens:collecting_events user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :collecting_events => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Building new collecting events...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')

          get_tw_collecting_event_id = {} # key = sfUniqueLocColEvents.UniqueID, value = TW.collecting_event_id

          path = @args[:data_directory] + 'sfUniqueLocColEvents.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          # FileID
          # Level1ID	Level2ID	Level3ID	Level4ID
          # Latitude	Longitude	PrecisionCode
          # Elevation	MaxElevation
          # TimePeriodID
          # LocalityDetail
          # TimeDetail
          # DataFlags: bitwise, 1 = ecological relationship, 2 = character data (not implemented?), 4 = image, 8 = sound, 16 = include specimen locality in maps, 32 = image of specimen label
          # Country	State	County
          # BodyOfWater
          # PrecisionRadius
          # LatLongFrom
          # CollectorName
          # Year MonthDay
          # DaysToEnd
          # UniqueID

          counter = 0

          file.each do |row|
            project_id = get_tw_project_id(row['FileID']).to_i

            logger.info "Working with TW.project_id = #{project_id}, UniqueID = #{row['UniqueID']} (count #{counter += 1}) \n"


            # TODO: review
            end_date = nil
            end_date_day, end_date_month, end_date_year = nil, nil, nil
            if !row['DaysToEnd'].blank?
              start_date = Date.new(
                  [row['year'], row['month'], row['day']].join('/')
              )

              end_date = row['DaysToEnd'].to_i.days.since(start_date)
            end


            # TODO:
            #  PrecisionCode?  integer
            #  handle TimePeriodID as data attribute  integer (bitwise)
            #  handle TimeDetail as data attribute  string
            #  handle DataFlags as (import predicate)? integer (bitwise)
            #  handle BodyOfWater as data attribute?   string
            #
            #
            #  handle PrecisionRadius as Georeference precision
            #  handle LatLongFrom   of type Verbatim GeoReference

           #  some_precisions_radius_conversion   = row['PrecisionRadius'].to_i  * 10 # METERS

            begin
              # c = CollectingEvent.create!(
              #     verbatim_latitude: row['Latitude'],
              #     verbatim_longitude: row['Longitude'],
              #     maximum_elevation: row['MaxElevation'],
              #     collectors: row['CollectoName'],
              #     start_date_day: row['day'],
              #     start_date_month: row['month'],
              #     start_date_year: row['year'],
              #     end_date_day: (end_date ? end_date.day : nil),
              #     end_date_month: (end_date ? end_date.month : nil),
              #     end_date_year: (end_date ? end_date.year : nil),
              #     geographic_area: get_tw_geographic_area(row),
              #
              #     project_id: project_id
              #
              #     # add in data attributes, import_predicate,
              #     # georeferences_attributes: [
              #      {
              #          type: 'Georeference::VerbatimGeoreference',
              #          error_radius: some_precisions_radius_conversion,
              #          geographic_item_attributes: {
              #              # JIM WILL HELP YOU WITH THE Rgeo::Point construction
              #              # basically, the lat long values go here
              #          }
              #
              #      }
              #     # ],
              #
              #
              #
              # )

              get_tw_collecting_event_id[row['UniqueID']] = c.id.to_s

              logger.info "UniqueID #{row['UniqueID']} written"
            rescue ActiveRecord::RecordInvalid

              logger.info "Failed on UniqueID #{row['UniqueID']}"

            end
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFUniqueIDToTWCollectingEventID', get_tw_collecting_event_id)

        end

        # Find a TW geographic_area
        def get_tw_geographic_area(row)
          # we can lookup TDWG id, is this enough to represent country/state/county
          tdwg_id = [
              row['Level1ID'],
              row['Level2ID'],
              row['Level3ID'],
              row['Level4ID'] # TODO: we have to pad dashes here to match off values
          ].select { |a| a.length > 0 }.join

          logger.info "target tdwg id: #{tdwg_id}"

          # Lookup the TDWG geographic area
          tdwg_area = GeographicArea.where(tdwgID: tdwg_id).last.tdwgID

          # Find values in country/state/county
          finest_sf_level = [
              row['country'],
              row['state'],
              row['county']
          ].select { |a| !a.blank? }

          # If there is no value, just return the tdwg based match
          if finest_sf_level.empty?
            return tdwg_area

            # If a value is provided for country/state/county, and that value matches the name we found for tdwg, we're done
          elsif tdwg_area.name == finest_sf_level.last
            return tdwg_area

          else
            # TODO: do something else
            return nil
          end

        end


        desc 'time rake tw:project_import:sf_import:specimens:import_two_specimen_lists user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :import_two_specimen_lists => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running new specimen lists (hash, array)...'

          get_new_preserved_specimen_id = [] # array of SF.SpecimenIDs with BasisOfRecord = 0 (not stated) but with DepoID or specimen count
          get_sf_unique_id = {} # key = SF.SpecimenID, value = sfUniqueLocColEvents.UniqueID


          logger.info '1. Getting new preferred specimen ids'

          path = @args[:data_directory] + 'sfAddPreservedSpecimens.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            get_new_preserved_specimen_id.push(row[0])
          end


          logger.info '2. Getting SF SpecimenID to UniqueID hash'

          count = 0

          path = @args[:data_directory] + 'sfSpecimenToUniqueIDs.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            puts "SpecimenID = #{row['SpecimenID']}, count #{count += 1} \n"
            get_sf_unique_id[row['SpecimenID']] = row['UniqueLocColEventID']
          end


          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFNewPreservedSpecimens', get_new_preserved_specimen_id)
          import.set('SFSpecimenToUniqueIDs', get_sf_unique_id)

          puts 'SFNewPreservedSpecimens'
          ap get_new_preserved_specimen_id

          puts 'SFSpecimenToUniqueIDs'
          ap get_sf_unique_id

        end


      end
    end
  end
end
