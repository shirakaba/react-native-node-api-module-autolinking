#include <node_api.h>

static napi_value Add(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2];
    napi_get_cb_info(env, info, &argc, args, NULL, NULL);

    if (argc < 2) return NULL;

    double value1, value2;
    napi_get_value_double(env, args[0], &value1);
    napi_get_value_double(env, args[1], &value2);

    napi_value sum;
    napi_create_double(env, value1 + value2, &sum);

    return sum;
}

static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc = {"add", NULL, Add, NULL, NULL, NULL, napi_default, NULL};
    napi_define_properties(env, exports, 1, &desc);
    return exports;
}

NAPI_MODULE(NODE_GYP_MODULE_NAME, Init)
