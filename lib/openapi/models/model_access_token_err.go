/*
 * NRF OAuth2
 *
 * NRF OAuth2 Authorization
 *
 * API version: 1.0.1
 * Generated by: OpenAPI Generator (https://openapi-generator.tech)
 */

package models

type AccessTokenErr struct {
	Error string `json:"error" yaml:"error" bson:"error" mapstructure:"Error"`
	ErrorDescription string `json:"error_description,omitempty" yaml:"error_description" bson:"error_description" mapstructure:"ErrorDescription"`
	ErrorUri string `json:"error_uri,omitempty" yaml:"error_uri" bson:"error_uri" mapstructure:"ErrorUri"`
}
