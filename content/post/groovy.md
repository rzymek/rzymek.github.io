+++
bigimg = ""
date = "2014-07-11T10:54:24+02:00"
subtitle = ""
title = "groovy hate"
draft = true
+++

import groovy.transform.CompileStatic
import com.pg.cmk.common.utils.SQLHelper


@CompileStatic
class KeyPerspectiveCommentDTO {
    String presetCode
    int drillDownLevel
    String comment
    String chart

    Map<String, Serializable> toParameters() {
        LinkedHashMap<java.lang.String, java.io.Serializable> parameters = [
                presetCode    : presetCode,
                drillDownLevel: drillDownLevel,
                comment       : SQLHelper.truncateString(comment, 255),
                chart         : chart
        ]
        return parameters
    }

}

    Error:(14, 76) Groovyc: [Static type checking] - Incompatible generic argument types. Cannot assign 
      java.util.LinkedHashMap <java.lang.String, java.io.Serializable> to: 
      java.util.LinkedHashMap <java.lang.String, java.io.Serializable>