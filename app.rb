require 'sinatra'
require 'caxlsx'
require 'tempfile'
require 'fileutils'
require 'rack/protection'

# Redireciona todo tráfego HTTP para HTTPS
before do
  if request.scheme == 'http'
    redirect request.url.sub('http', 'https'), 301
  end
end

# Headers de segurança adicionais
before do
  headers 'X-Content-Type-Options' => 'nosniff',
          'X-Frame-Options' => 'DENY',
          'Referrer-Policy' => 'no-referrer',
          'Permissions-Policy' => 'camera=(), microphone=(), geolocation=()',
          'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains; preload'
end

# Configurações do Sinatra
set :public_folder, 'public'
set :port, ENV['PORT'] || 4567
set :bind, '0.0.0.0'

# Middleware de segurança
use Rack::Protection
use Rack::Protection::XSSHeader
use Rack::Protection::FrameOptions
use Rack::Protection::HttpOrigin

# Página inicial
get '/' do
  erb :index
end

# Sanitização de dados para prevenir fórmulas perigosas
def sanitize_excel_cell(text)
  return "" unless text
  t = text.to_s.strip
  t.start_with?('=', '+', '-', '@') ? "'#{t}" : t
end

# Rota de salvamento
post '/salvar' do
  nome = params[:nome]
  np = params[:np]
  tarefa = params[:tarefa]
  descricao = params[:descricao]
  tempo = params[:tempo]

  # Cria um arquivo temporário
  temp_file = Tempfile.new(["relatorio_", ".xlsx"])

  # Gera o relatório Excel
  Axlsx::Package.new do |p|
    p.workbook.add_worksheet(name: "Relatório") do |sheet|
      sheet.add_row ["Nome", "NP", "Tarefa", "Descrição", "Tempo"]
      sheet.add_row [
        sanitize_excel_cell(nome),
        sanitize_excel_cell(np),
        sanitize_excel_cell(tarefa),
        sanitize_excel_cell(descricao),
        sanitize_excel_cell(tempo)
      ]
    end
    p.serialize(temp_file.path)
  end

  # Prepara o nome do arquivo para download
  safe_tarefa = tarefa.strip.gsub(/\s+/, '_').gsub(/[^0-9A-Za-z_]/, '')
  timestamp = Time.now.strftime("%Y%m%d%H%M%S")
  download_name = "relatorio_#{safe_tarefa}_#{timestamp}.xlsx"

  # Envia como download
  send_file temp_file.path,
            filename: download_name,
            type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
end
