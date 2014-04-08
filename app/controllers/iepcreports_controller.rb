class IepcreportsController < ApplicationController
  menu_item :activity
  before_filter :find_optional_project, :set_as_private
  accept_rss_auth :index
  require 'date'
  require 'axlsx'
  include ActionView::Helpers::TextHelper

  def index

  end

  def set_as_private
    expires_now
  end

  def activity
    @allprojects = Project.all


    projects_by_id = {}
    @allprojects.each do |project|
      projects_by_id[project.id] = project.identifier
    end
    today = Date.today;

    @date_from = params[:del].nil? ? (today.at_beginning_of_week) : (Date.parse params[:del])
    @date_to   = params[:al].nil? ? (today.at_end_of_week) : (Date.parse params[:al])
    @direccion = params[:id].nil? ? 'direccion-general' : params[:id]

    @author = (params[:user_id].blank? ? nil : User.active.find(params[:user_id]))

    @activity = Redmine::Activity::Fetcher.new(User.current,
                                               :project => @project,
                                               :with_subprojects => 1,
                                               :author => @author)
    @activity.default_scope!
    events = @activity.events(@date_from, @date_to)
    @events_by_day = events.group_by {|event| event.attributes['project_id']}

    @events_by_day = @events_by_day.sort_by {|key, issue| key.nil? ? 'a' : projects_by_id[key] }

  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def outdatedCalendar
    @allprojects = Project.all

    projects_by_id = {
        1 => -2,   # Programa Operativo Anual
        2 => -1,   # Secretaría Ejecutiva
        3 => 0,   # Dirección General
        4 => 1,   # Administración y finanzas
        5 => 2,   # Capacitación Electoral
        6 => 3,   # Informática
        7 => 4,   # Jurídico
        8 => 5,   # Organización
        9 => 12,  # Fiscalización
        10 => 6,  # Comunicación Social
        11 => 7,  # Participación ciudadana
        12 => 8,  # Secretaría Técnica
        13 => 9,  # Transparencia
        14 => 10, # Unidad Editorial
        15 => 11, # Prerrogativas
        16 => 13, # Contraloría
        17 => 14, # Presidencia
        18 => 15  # Consejo General
    }

    #@allprojects.each do |project|
    #  projects_by_id[project.id] = project.identifier
    #end

    nextweek   = Date.today.at_end_of_week + 2
    direccion  = params[:id].nil? ? 'direccion-general' : params[:id]

    @date_from = params[:del].nil? ? (nextweek.at_beginning_of_week) : (Date.parse params[:del])
    @date_to   = params[:al].nil? ? (nextweek.at_end_of_week) : (Date.parse params[:al])
    @direccion = Project.find_by_identifier direccion
    @author    = (params[:user_id].blank? ? nil : User.active.find(params[:user_id]))

    direcciones = [@direccion.id]
    @direccion.children.each do |subdireccion|
      direcciones.push subdireccion.id
    end

    @issues = Issue.open
                   .where('project_id in (' + direcciones.join(', ') + ')')
                   .where('(start_date <= ? and done_ratio < 100) or (start_date <= ? and start_date >= ?)', @date_to, @date_to, @date_from)
                   .where('tracker_id not in (4,5)')
                   .order('start_date DESC')
                   .group_by {|issue| issue.attributes['project_id']}

    @issues = @issues.sort_by {|key, issue| projects_by_id[key] }

    if request.fullpath.index('excel')
      Axlsx::Package.new do |p|
        wb = p.workbook
        wb.styles do |s|
          heading1    = s.add_style alignment: {horizontal: :center}, b: true, sz: 12, bg_color: 'FFFFFF', fg_color: '000000'
          heading3    = s.add_style alignment: {horizontal: :left}, b: true, sz: 11, bg_color: 'FFFFFF', fg_color: '000000'
          descripcion = s.add_style :alignment => {wrap_text: true}
          date = s.add_style(:format_code => 'yyyy-mm-dd', :b => true, alignment: {horizontal: :left})
          padded = s.add_style(:format_code => '00#')
          percent = s.add_style(:format_code => '0000%')

          wb.add_worksheet(:name => 'Agenda de actividades') do |sheet|
            sheet.add_row ['Agenda de actividades del ' + @date_from.to_s + ' al ' + @date_to.to_s], style: heading1
            sheet.merge_cells("A#{sheet.rows.length}:D#{sheet.rows.length}")
            sheet.add_row []

            @issues.each do |key, project|
              sheet.add_row [@allprojects[key-1]], :style => heading3
              sheet.merge_cells("A#{sheet.rows.length}:D#{sheet.rows.length}")
              project.each do |issue|
                sheet.add_row [issue.done_ratio.to_s + '%', '[' + issue.id.to_s + ']', issue.start_date, truncate(issue.event_title.partition(':')[2], :length => 140)], :style => [percent, padded, date, padded]
                if issue.description.length > 0
                  sheet.add_row [nil,nil,issue.description], :style => descripcion
                  sheet.merge_cells("C#{sheet.rows.length}:D#{sheet.rows.length}")
                end
              end
              sheet.add_row []
            end

            sheet.column_widths 8, 10, 12, 140
          end

        end
        p.serialize("#{Rails.root}/tmp/agenda_actividades.xlsx")
      end
      send_file "#{Rails.root}/tmp/agenda_actividades.xlsx", :type => "application/xlsx", :x_sendfile => true
    end

  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def calendar
    projects_by_id = {
        1 => -2,   # Programa Operativo Anual
        2 => -1,   # Secretaría Ejecutiva
        3 => 0,   # Dirección General
        4 => 1,   # Administración y finanzas
        5 => 2,   # Capacitación Electoral
        6 => 3,   # Informática
        7 => 4,   # Jurídico
        8 => 5,   # Organización
        9 => 12,  # Fiscalización
        10 => 6,  # Comunicación Social
        11 => 7,  # Participación ciudadana
        12 => 8,  # Secretaría Técnica
        13 => 9,  # Transparencia
        14 => 10, # Unidad Editorial
        15 => 11, # Prerrogativas
        16 => 13, # Contraloría
        17 => -3, # Presidencia
        18 => -4  # Consejo General
    }
    nextweek         = Date.today.at_end_of_week + 2
    direccion_param  = params[:id].nil? ? 'direccion-general' : params[:id]
    @date_from       = params[:del].nil? ? (nextweek.at_beginning_of_week) : (Date.parse params[:del])
    @date_to          = params[:al].nil? ? (nextweek.at_end_of_week) : (Date.parse params[:al])

    @allprojects = Project.all
      .delete_if {|project| projects_by_id[project.id] < 0}
      .sort_by {|project| projects_by_id[project.id]}

    @direccion = Project.find_by_identifier direccion_param
    @direcciones = [@direccion]
    @direccion.children.each do |subdireccion|
      @direcciones.push subdireccion
    end
    @direcciones.sort_by {|project| projects_by_id[project.id]}

    @direcciones_y_tareas = {}

    @direcciones.each do |project|
      @direcciones_y_tareas[project] = Issue.open
        .where('project_id = ?', project.id)
        .where('parent_id IS NULL')
        .where('(start_date <= ? and done_ratio < 100) or (start_date <= ? and start_date >= ?)', @date_to, @date_to, @date_from)
        .order('start_date DESC')
    end

  rescue ActiveRecord::RecordNotFound
    render_404
  end

  private

  def find_optional_project
    return true unless params[:id]
    @project = Project.find(params[:id])
    authorize
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
