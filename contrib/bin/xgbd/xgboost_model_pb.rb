# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: xgboost/xgboost_model.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("xgboost/xgboost_model.proto", :syntax => :proto3) do
    add_message "xgboost_model.XGBoostParameters" do
      proto3_optional :eta, :float, 1
      proto3_optional :max_depth, :uint32, 2
      proto3_optional :n_estimators, :uint32, 3
      proto3_optional :min_samples_split, :uint32, 4
      proto3_optional :subsample, :float, 5
      proto3_optional :colsample_bytree, :float, 6
      proto3_optional :colsample_bylevel, :float, 7
      proto3_optional :colsample_bynode, :float, 8
      proto3_optional :tree_method, :enum, 9, "xgboost_model.TreeMethod"
      proto3_optional :scale_pos_weight, :float, 10
    end
    add_message "xgboost_model.LightGbmParameters" do
    end
    add_message "xgboost_model.XGBoostModel" do
      proto3_optional :model_type, :string, 1
      proto3_optional :response, :string, 2
      proto3_optional :parameters, :message, 3, "xgboost_model.XGBoostParameters"
      proto3_optional :classification, :bool, 4
      map :name_to_col, :string, :uint32, 5
    end
    add_enum "xgboost_model.TreeMethod" do
      value :UNDEFINED, 0
      value :AUTO, 1
      value :EXACT, 2
      value :APPROX, 3
      value :HIST, 4
    end
  end
end

module XgboostModel
  XGBoostParameters = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("xgboost_model.XGBoostParameters").msgclass
  LightGbmParameters = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("xgboost_model.LightGbmParameters").msgclass
  XGBoostModel = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("xgboost_model.XGBoostModel").msgclass
  TreeMethod = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("xgboost_model.TreeMethod").enummodule
end
