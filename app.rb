require 'sinatra'
require 'caxlsx'
require 'tempfile'
require 'fileutils'

set :public_folder, 'public'
set :port, ENV['PORT'] || 4567
set :bind, '0.0.0.0'

get '/' do
  erb :index
end

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
      sheet.add_row [nome, np, tarefa, descricao, tempo]
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
