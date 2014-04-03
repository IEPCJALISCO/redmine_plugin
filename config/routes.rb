# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'reports',                             to: 'iepcreports#index',    as: 'reportes'

get 'reports/activity',                    to: 'iepcreports#activity', as: 'reporteActividades'
get 'reports/:del/:al/:id/activity',       to: 'iepcreports#activity', as: 'reporteActividadesConFecha'

get 'reports/calendar',                    to: 'iepcreports#calendar', as: 'reporteCalendario'
get 'reports/calendar/:del/:al/:id',       to: 'iepcreports#calendar', as: 'reporteCalendarioConFecha'

get 'reports/calendar/excel',              to: 'iepcreports#calendar', as: 'reporteCalendarioExcel'
get 'reports/calendar/:del/:al/:id/excel', to: 'iepcreports#calendar', as: 'reporteCalendarioConFechaExcel'

