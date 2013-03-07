#include "erl_nif.h"
#include "stdlib.h"
#include "stdio.h"


static ErlNifResourceType* bint_RESOURCE = NULL;


typedef struct resource_t
{
   int count;
   int arraysz;
   ERL_NIF_TERM *array;
}resource_t;


// Prototypes
static ERL_NIF_TERM bint_tobin(ErlNifEnv* env, int argc,
                                   const ERL_NIF_TERM argv[]);
static ERL_NIF_TERM bint_toterm(ErlNifEnv* env, int argc,
                                          const ERL_NIF_TERM argv[]);

static void add_element(resource_t *r, ERL_NIF_TERM t);

static ErlNifFunc nif_funcs[] =
{
    {"tobin", 1, bint_tobin},
    {"toterm", 1, bint_toterm},
};

static ERL_NIF_TERM bint_tobin(ErlNifEnv* env, int argc,
                                   const ERL_NIF_TERM argv[])
{
    if(argc != 1) return enif_make_badarg(env);

    return enif_make_tuple(env, enif_make_atom(env, "ok"));
}


static ERL_NIF_TERM bint_toterm(ErlNifEnv* env, int argc,
                                             const ERL_NIF_TERM argv[])
{

  int i;
  ErlNifBinary bin;
  ERL_NIF_TERM result;

  resource_t *r = enif_alloc(sizeof(resource_t));
  r->count = 0;
  r->arraysz = 32;
  r->array = enif_alloc(32);

  if(argc != 1) return enif_make_badarg(env);
  enif_inspect_binary(env, argv[0], &bin);

  // if(ERL_IS_INTEGER(bin.data[0]))
  add_element(r, enif_make_tuple2(env, enif_make_atom(env, "binary_size"), 
             enif_make_int(env, bin.size)));

  for (i = 0; i < bin.size; ++i)
  {
    if(bin.data[i] == 'a')
    {
      add_element(r, enif_make_int(env, bin.data[++i]));
    }
  }

  result =  enif_make_tuple2(env, enif_make_atom(env, "ok"), 
                            enif_make_tuple_from_array(env, r->array, r->count));

  enif_free(r->array);
  enif_free(r);

  return result;
}                        

static void bint_resource_cleanup(ErlNifEnv* env, void* arg)
{
    /* Delete any dynamically allocated memory stored in bint_handle */
    /* bint_handle* handle = (bint_handle*)arg; */
}

static int on_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info)
{
    ErlNifResourceFlags flags = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;
    ErlNifResourceType* rt = enif_open_resource_type(env, NULL,
                                                     "bint_resource",
                                                     &bint_resource_cleanup,
                                                     flags, NULL);
    if (rt == NULL)
        return -1;

    bint_RESOURCE = rt;

    return 0;
}


static void add_element(resource_t *r, ERL_NIF_TERM t)
{
    if (r->count * sizeof(ERL_NIF_TERM) >= r->arraysz) {
      r->arraysz *= 2;
      r->array = enif_realloc(r->array, r->arraysz);
    }
    r->array[r->count] = t;
    ++(r->count);
}


static void handle_list(env)
{
  // enif_make_list_from_array(ErlNifEnv* env, const ERL_NIF_TERM arr[], unsigned cnt)
}

ERL_NIF_INIT(bint, nif_funcs, &on_load, NULL, NULL, NULL);
