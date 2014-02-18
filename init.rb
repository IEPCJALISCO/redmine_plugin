require 'redmine'
require_dependency 'iepc_my_controller_patch'

Redmine::Plugin.register :iepc do
  name 'Iepcjalisco plugin'
  author 'iZam b. <ismael.barragan@iepcjalisco.org.mx>'
  description 'Plugin con funciones adicionales para el IEPC Jalisco'
  version '0.0.2'
  url 'http://wwww.iepcjalisco.org.mx/'

  menu :top_menu, :iepc, { :controller => 'iepc', :action => 'index' }, :caption => :reports
end
