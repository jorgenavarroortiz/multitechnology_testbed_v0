/*
 * NRF NFManagement Service
 *
 * NRF NFManagement Service
 *
 * API version: 1.0.1
 * Generated by: OpenAPI Generator (https://openapi-generator.tech)
 */

package models

type InvalidParam struct {
	Param string `json:"param" yaml:"param" bson:"param" mapstructure:"Param"`
	Reason string `json:"reason,omitempty" yaml:"reason" bson:"reason" mapstructure:"Reason"`
}
