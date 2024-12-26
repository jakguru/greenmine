module Webhooks
  class GenericController < ApplicationController
    skip_before_action :verify_authenticity_token, :check_if_login_required

    def handle
      case params[:model]
      when "RemoteGit::Commit"
        model = RemoteGit::Commit.find(params[:id])
      when "RemoteGit::MergeRequest"
        model = RemoteGit::MergeRequest.find(params[:id])
      when "RemoteGit::Pipeline"
        model = RemoteGit::Pipeline.find(params[:id])
      when "RemoteGit::Release"
        model = RemoteGit::Release.find(params[:id])
      when "RemoteGit::Tag"
        model = RemoteGit::Tag.find(params[:id])
      end
      unless model
        render json: {error: "Model not found"}, status: :not_found
        return
      end
      model.refresh
      Rails.logger.info model.inspect
      render json: {accepted: true}, status: :accepted
    end
  end
end
