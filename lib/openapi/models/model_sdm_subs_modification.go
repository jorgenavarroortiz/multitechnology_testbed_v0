/*
 * Nudm_SDM
 *
 * Nudm Subscriber Data Management Service
 *
 * API version: 2.0.0
 * Generated by: OpenAPI Generator (https://openapi-generator.tech)
 */

package models

import (
	"time"
)

type SdmSubsModification struct {
	Expires *time.Time `json:"expires,omitempty" yaml:"expires" bson:"expires" mapstructure:"Expires"`
}
