/*
 * Npcf_SMPolicyControl
 *
 * Session Management Policy Control Service
 *
 * API version: 1.0.1
 * Generated by: OpenAPI Generator (https://openapi-generator.tech)
 */

package models

type FailureCode string

// List of FailureCode
const (
	FailureCode_UNK_RULE_ID            FailureCode = "UNK_RULE_ID"
	FailureCode_RA_GR_ERR              FailureCode = "RA_GR_ERR"
	FailureCode_SER_ID_ERR             FailureCode = "SER_ID_ERR"
	FailureCode_NF_MAL                 FailureCode = "NF_MAL"
	FailureCode_RES_LIM                FailureCode = "RES_LIM"
	FailureCode_MAX_NR_QO_S_FLOW       FailureCode = "MAX_NR_QoS_FLOW"
	FailureCode_MISS_FLOW_INFO         FailureCode = "MISS_FLOW_INFO"
	FailureCode_RES_ALLO_FAIL          FailureCode = "RES_ALLO_FAIL"
	FailureCode_UNSUCC_QOS_VAL         FailureCode = "UNSUCC_QOS_VAL"
	FailureCode_INCOR_FLOW_INFO        FailureCode = "INCOR_FLOW_INFO"
	FailureCode_PS_TO_CS_HAN           FailureCode = "PS_TO_CS_HAN"
	FailureCode_APP_ID_ERR             FailureCode = "APP_ID_ERR"
	FailureCode_NO_QOS_FLOW_BOUND      FailureCode = "NO_QOS_FLOW_BOUND"
	FailureCode_FILTER_RES             FailureCode = "FILTER_RES"
	FailureCode_MISS_REDI_SER_ADDR     FailureCode = "MISS_REDI_SER_ADDR"
	FailureCode_CM_END_USER_SER_DENIED FailureCode = "CM_END_USER_SER_DENIED"
	FailureCode_CM_CREDIT_CON_NOT_APP  FailureCode = "CM_CREDIT_CON_NOT_APP"
	FailureCode_CM_AUTH_REJ            FailureCode = "CM_AUTH_REJ"
	FailureCode_CM_USER_UNK            FailureCode = "CM_USER_UNK"
	FailureCode_CM_RAT_FAILED          FailureCode = "CM_RAT_FAILED"
	FailureCode_UE_STA_SUSP            FailureCode = "UE_STA_SUSP"
)
