#logging of PETSc's internal performance

export Log #PETSc log

type Log{T}
    viewer::C.PetscViewer{T}
    stage::Integer
    function Log(view::C.PetscViewer{T}=nothing)
        viewer=view
        l = new(viewer,0)
        chk(C.PetscLogBegin())
        # no finalizer because PetscFinalize() handles this
        return l
    end
end

function dump{T}(logger::Log{T}, filename=nothing)
    c_fn = filename
    if filename != nothing
        c_fn = convert(Cstring, filename)
    end
    chk(C.PetscLogDump(c_fn))
end

function petscview{T}(logger::Log{T})
    chk(C.PetscLogView(logger.view))
end

function stage_push{T}(logger::Log{T}, name=nothing)
    if name == nothing
        chk(C.PetscLogStagePush(logger.stage + 1))
    else
        cname = convert(Cstring,name)
        stage_arr = PetscLogStage[stage+1]
        chk(C.PetscLogStagePush(logger.stage + 1))
        chk(C.PetscLogStageRegister(cname),stage_arr)
    end
end

function stage_pop{T}(logger::Log{T})
    chk(C.PetscLogStatePop())
end
