; ModuleID = 'matmul.cpp'
source_filename = "matmul.cpp"
target datalayout = "e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-p7:160:256:256:32-p8:128:128-p9:192:256:256:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7:8:9"
target triple = "amdgcn-amd-amdhsa"

@_ZZ12matmul_tiledPKfS0_PfiE5tileA = internal unnamed_addr addrspace(3) global [16 x [16 x float]] undef, align 16
@_ZZ12matmul_tiledPKfS0_PfiE5tileB = internal unnamed_addr addrspace(3) global [16 x [16 x float]] undef, align 16
@__hip_cuid_b0718004ecdb8403 = addrspace(1) global i8 0
@llvm.compiler.used = appending addrspace(1) global [1 x ptr] [ptr addrspacecast (ptr addrspace(1) @__hip_cuid_b0718004ecdb8403 to ptr)], section "llvm.metadata"

; Function Attrs: mustprogress nofree norecurse nosync nounwind memory(argmem: readwrite)
define protected amdgpu_kernel void @_Z12matmul_naivePKfS0_Pfi(ptr addrspace(1) noundef readonly captures(none) %0, ptr addrspace(1) noundef readonly captures(none) %1, ptr addrspace(1) noundef writeonly captures(none) %2, i32 noundef %3) local_unnamed_addr #0 {
  %5 = tail call i32 @llvm.amdgcn.workgroup.id.y()
  %6 = tail call ptr addrspace(4) @llvm.amdgcn.implicitarg.ptr()
  %7 = getelementptr inbounds nuw i8, ptr addrspace(4) %6, i64 14
  %8 = load i16, ptr addrspace(4) %7, align 2, !tbaa !7
  %9 = zext i16 %8 to i32
  %10 = mul i32 %5, %9
  %11 = tail call noundef range(i32 0, 1024) i32 @llvm.amdgcn.workitem.id.y()
  %12 = add i32 %10, %11
  %13 = tail call i32 @llvm.amdgcn.workgroup.id.x()
  %14 = getelementptr inbounds nuw i8, ptr addrspace(4) %6, i64 12
  %15 = load i16, ptr addrspace(4) %14, align 4, !tbaa !7
  %16 = zext i16 %15 to i32
  %17 = mul i32 %13, %16
  %18 = tail call noundef range(i32 0, 1024) i32 @llvm.amdgcn.workitem.id.x()
  %19 = add i32 %17, %18
  %20 = icmp slt i32 %12, %3
  %21 = icmp slt i32 %19, %3
  %22 = and i1 %20, %21
  br i1 %22, label %23, label %47

23:                                               ; preds = %4
  %24 = icmp sgt i32 %3, 0
  %25 = mul nsw i32 %12, %3
  br i1 %24, label %31, label %26

26:                                               ; preds = %31, %23
  %27 = phi float [ 0.000000e+00, %23 ], [ %44, %31 ]
  %28 = add nsw i32 %25, %19
  %29 = sext i32 %28 to i64
  %30 = getelementptr inbounds float, ptr addrspace(1) %2, i64 %29
  store float %27, ptr addrspace(1) %30, align 4
  br label %47

31:                                               ; preds = %23, %31
  %32 = phi i32 [ %45, %31 ], [ 0, %23 ]
  %33 = phi float [ %44, %31 ], [ 0.000000e+00, %23 ]
  %34 = add nsw i32 %32, %25
  %35 = sext i32 %34 to i64
  %36 = getelementptr inbounds float, ptr addrspace(1) %0, i64 %35
  %37 = load float, ptr addrspace(1) %36, align 4
  %38 = mul nuw nsw i32 %32, %3
  %39 = add nsw i32 %38, %19
  %40 = sext i32 %39 to i64
  %41 = getelementptr inbounds float, ptr addrspace(1) %1, i64 %40
  %42 = load float, ptr addrspace(1) %41, align 4
  %43 = fmul contract float %37, %42
  %44 = fadd contract float %33, %43
  %45 = add nuw nsw i32 %32, 1
  %46 = icmp eq i32 %45, %3
  br i1 %46, label %26, label %31, !llvm.loop !11

47:                                               ; preds = %26, %4
  ret void
}

; Function Attrs: convergent mustprogress nofree norecurse nounwind
define protected amdgpu_kernel void @_Z12matmul_tiledPKfS0_Pfi(ptr addrspace(1) noundef readonly captures(none) %0, ptr addrspace(1) noundef readonly captures(none) %1, ptr addrspace(1) noundef writeonly captures(none) %2, i32 noundef %3) local_unnamed_addr #1 {
  %5 = tail call noundef range(i32 0, 1024) i32 @llvm.amdgcn.workitem.id.x()
  %6 = tail call noundef range(i32 0, 1024) i32 @llvm.amdgcn.workitem.id.y()
  %7 = tail call noundef i32 @llvm.amdgcn.workgroup.id.y()
  %8 = shl i32 %7, 4
  %9 = add i32 %8, %6
  %10 = tail call noundef i32 @llvm.amdgcn.workgroup.id.x()
  %11 = shl i32 %10, 4
  %12 = add i32 %11, %5
  %13 = icmp sgt i32 %3, 0
  br i1 %13, label %14, label %54

14:                                               ; preds = %4
  %15 = add nuw nsw i32 %3, 15
  %16 = lshr i32 %15, 4
  %17 = icmp slt i32 %9, %3
  %18 = mul nsw i32 %3, %9
  %19 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 %5
  %20 = icmp slt i32 %12, %3
  %21 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 %6, i32 %5
  %22 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 0
  %23 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 0, i32 %5
  %24 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 1
  %25 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 1, i32 %5
  %26 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 2
  %27 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 2, i32 %5
  %28 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 3
  %29 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 3, i32 %5
  %30 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 4
  %31 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 4, i32 %5
  %32 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 5
  %33 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 5, i32 %5
  %34 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 6
  %35 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 6, i32 %5
  %36 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 7
  %37 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 7, i32 %5
  %38 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 8
  %39 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 8, i32 %5
  %40 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 9
  %41 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 9, i32 %5
  %42 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 10
  %43 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 10, i32 %5
  %44 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 11
  %45 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 11, i32 %5
  %46 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 12
  %47 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 12, i32 %5
  %48 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 13
  %49 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 13, i32 %5
  %50 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 14
  %51 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 14, i32 %5
  %52 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileA, i32 0, i32 %6, i32 15
  %53 = getelementptr inbounds nuw [16 x [16 x float]], ptr addrspace(3) @_ZZ12matmul_tiledPKfS0_PfiE5tileB, i32 0, i32 15, i32 %5
  br label %59

54:                                               ; preds = %82, %4
  %55 = phi float [ 0.000000e+00, %4 ], [ %147, %82 ]
  %56 = icmp slt i32 %9, %3
  %57 = icmp slt i32 %12, %3
  %58 = and i1 %56, %57
  br i1 %58, label %150, label %155

59:                                               ; preds = %14, %82
  %60 = phi float [ 0.000000e+00, %14 ], [ %147, %82 ]
  %61 = phi i32 [ 0, %14 ], [ %148, %82 ]
  %62 = shl nsw i32 %61, 4
  %63 = add nuw nsw i32 %62, %5
  %64 = add nuw nsw i32 %62, %6
  %65 = icmp slt i32 %63, %3
  %66 = select i1 %17, i1 %65, i1 false
  br i1 %66, label %67, label %72

67:                                               ; preds = %59
  %68 = add nsw i32 %63, %18
  %69 = sext i32 %68 to i64
  %70 = getelementptr inbounds float, ptr addrspace(1) %0, i64 %69
  %71 = load float, ptr addrspace(1) %70, align 4
  br label %72

72:                                               ; preds = %59, %67
  %73 = phi contract float [ %71, %67 ], [ 0.000000e+00, %59 ]
  store float %73, ptr addrspace(3) %19, align 4
  %74 = icmp slt i32 %64, %3
  %75 = and i1 %20, %74
  br i1 %75, label %76, label %82

76:                                               ; preds = %72
  %77 = mul nuw nsw i32 %64, %3
  %78 = add nsw i32 %77, %12
  %79 = sext i32 %78 to i64
  %80 = getelementptr inbounds float, ptr addrspace(1) %1, i64 %79
  %81 = load float, ptr addrspace(1) %80, align 4
  br label %82

82:                                               ; preds = %72, %76
  %83 = phi contract float [ %81, %76 ], [ 0.000000e+00, %72 ]
  store float %83, ptr addrspace(3) %21, align 4
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier()
  fence syncscope("workgroup") acquire
  %84 = load float, ptr addrspace(3) %22, align 16
  %85 = load float, ptr addrspace(3) %23, align 4
  %86 = fmul contract float %84, %85
  %87 = fadd contract float %60, %86
  %88 = load float, ptr addrspace(3) %24, align 4
  %89 = load float, ptr addrspace(3) %25, align 4
  %90 = fmul contract float %88, %89
  %91 = fadd contract float %87, %90
  %92 = load float, ptr addrspace(3) %26, align 8
  %93 = load float, ptr addrspace(3) %27, align 4
  %94 = fmul contract float %92, %93
  %95 = fadd contract float %91, %94
  %96 = load float, ptr addrspace(3) %28, align 4
  %97 = load float, ptr addrspace(3) %29, align 4
  %98 = fmul contract float %96, %97
  %99 = fadd contract float %95, %98
  %100 = load float, ptr addrspace(3) %30, align 16
  %101 = load float, ptr addrspace(3) %31, align 4
  %102 = fmul contract float %100, %101
  %103 = fadd contract float %99, %102
  %104 = load float, ptr addrspace(3) %32, align 4
  %105 = load float, ptr addrspace(3) %33, align 4
  %106 = fmul contract float %104, %105
  %107 = fadd contract float %103, %106
  %108 = load float, ptr addrspace(3) %34, align 8
  %109 = load float, ptr addrspace(3) %35, align 4
  %110 = fmul contract float %108, %109
  %111 = fadd contract float %107, %110
  %112 = load float, ptr addrspace(3) %36, align 4
  %113 = load float, ptr addrspace(3) %37, align 4
  %114 = fmul contract float %112, %113
  %115 = fadd contract float %111, %114
  %116 = load float, ptr addrspace(3) %38, align 16
  %117 = load float, ptr addrspace(3) %39, align 4
  %118 = fmul contract float %116, %117
  %119 = fadd contract float %115, %118
  %120 = load float, ptr addrspace(3) %40, align 4
  %121 = load float, ptr addrspace(3) %41, align 4
  %122 = fmul contract float %120, %121
  %123 = fadd contract float %119, %122
  %124 = load float, ptr addrspace(3) %42, align 8
  %125 = load float, ptr addrspace(3) %43, align 4
  %126 = fmul contract float %124, %125
  %127 = fadd contract float %123, %126
  %128 = load float, ptr addrspace(3) %44, align 4
  %129 = load float, ptr addrspace(3) %45, align 4
  %130 = fmul contract float %128, %129
  %131 = fadd contract float %127, %130
  %132 = load float, ptr addrspace(3) %46, align 16
  %133 = load float, ptr addrspace(3) %47, align 4
  %134 = fmul contract float %132, %133
  %135 = fadd contract float %131, %134
  %136 = load float, ptr addrspace(3) %48, align 4
  %137 = load float, ptr addrspace(3) %49, align 4
  %138 = fmul contract float %136, %137
  %139 = fadd contract float %135, %138
  %140 = load float, ptr addrspace(3) %50, align 8
  %141 = load float, ptr addrspace(3) %51, align 4
  %142 = fmul contract float %140, %141
  %143 = fadd contract float %139, %142
  %144 = load float, ptr addrspace(3) %52, align 4
  %145 = load float, ptr addrspace(3) %53, align 4
  %146 = fmul contract float %144, %145
  %147 = fadd contract float %143, %146
  fence syncscope("workgroup") release
  tail call void @llvm.amdgcn.s.barrier()
  fence syncscope("workgroup") acquire
  %148 = add nuw nsw i32 %61, 1
  %149 = icmp eq i32 %148, %16
  br i1 %149, label %54, label %59, !llvm.loop !13

150:                                              ; preds = %54
  %151 = mul nsw i32 %3, %9
  %152 = add nsw i32 %151, %12
  %153 = sext i32 %152 to i64
  %154 = getelementptr inbounds float, ptr addrspace(1) %2, i64 %153
  store float %55, ptr addrspace(1) %154, align 4
  br label %155

155:                                              ; preds = %150, %54
  ret void
}

; Function Attrs: convergent mustprogress nocallback nofree nounwind willreturn
declare void @llvm.amdgcn.s.barrier() #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef range(i32 0, 1024) i32 @llvm.amdgcn.workitem.id.x() #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef range(i32 0, 1024) i32 @llvm.amdgcn.workitem.id.y() #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef i32 @llvm.amdgcn.workgroup.id.x() #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef align 4 ptr addrspace(4) @llvm.amdgcn.implicitarg.ptr() #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef i32 @llvm.amdgcn.workgroup.id.y() #3

attributes #0 = { mustprogress nofree norecurse nosync nounwind memory(argmem: readwrite) "amdgpu-agpr-alloc"="0" "amdgpu-flat-work-group-size"="1,1024" "amdgpu-no-completion-action" "amdgpu-no-default-queue" "amdgpu-no-dispatch-id" "amdgpu-no-dispatch-ptr" "amdgpu-no-flat-scratch-init" "amdgpu-no-heap-ptr" "amdgpu-no-hostcall-ptr" "amdgpu-no-lds-kernel-id" "amdgpu-no-multigrid-sync-arg" "amdgpu-no-queue-ptr" "amdgpu-no-workgroup-id-x" "amdgpu-no-workgroup-id-z" "amdgpu-no-workitem-id-x" "amdgpu-no-workitem-id-z" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx1151" "target-features"="+16-bit-insts,+atomic-fadd-rtn-insts,+ci-insts,+dl-insts,+dot10-insts,+dot12-insts,+dot5-insts,+dot7-insts,+dot8-insts,+dot9-insts,+dpp,+gfx10-3-insts,+gfx10-insts,+gfx11-insts,+gfx8-insts,+gfx9-insts,+wavefrontsize32" "uniform-work-group-size"="true" }
attributes #1 = { convergent mustprogress nofree norecurse nounwind "amdgpu-agpr-alloc"="0" "amdgpu-flat-work-group-size"="1,1024" "amdgpu-no-completion-action" "amdgpu-no-default-queue" "amdgpu-no-dispatch-id" "amdgpu-no-dispatch-ptr" "amdgpu-no-flat-scratch-init" "amdgpu-no-heap-ptr" "amdgpu-no-hostcall-ptr" "amdgpu-no-implicitarg-ptr" "amdgpu-no-lds-kernel-id" "amdgpu-no-multigrid-sync-arg" "amdgpu-no-queue-ptr" "amdgpu-no-workgroup-id-x" "amdgpu-no-workgroup-id-z" "amdgpu-no-workitem-id-x" "amdgpu-no-workitem-id-z" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="gfx1151" "target-features"="+16-bit-insts,+atomic-fadd-rtn-insts,+ci-insts,+dl-insts,+dot10-insts,+dot12-insts,+dot5-insts,+dot7-insts,+dot8-insts,+dot9-insts,+dpp,+gfx10-3-insts,+gfx10-insts,+gfx11-insts,+gfx8-insts,+gfx9-insts,+wavefrontsize32" "uniform-work-group-size"="true" }
attributes #2 = { convergent mustprogress nocallback nofree nounwind willreturn }
attributes #3 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!opencl.ocl.version = !{!5}
!llvm.ident = !{!6}

!0 = !{i32 1, !"amdhsa_code_object_version", i32 600}
!1 = !{i32 1, !"amdgpu_printf_kind", !"hostcall"}
!2 = !{i32 1, !"wchar_size", i32 2}
!3 = !{i32 8, !"PIC Level", i32 2}
!4 = !{i32 1, !"MaxTLSAlign", i32 65536}
!5 = !{i32 2, i32 0}
!6 = !{!"clang version 21.0.0git (git@github.com:AMD-Lightning-Internal/llvm-project 590b9320a5be90e40268759c6203c01fde121e68)"}
!7 = !{!8, !8, i64 0}
!8 = !{!"short", !9, i64 0}
!9 = !{!"omnipotent char", !10, i64 0}
!10 = !{!"Simple C/C++ TBAA"}
!11 = distinct !{!11, !12}
!12 = !{!"llvm.loop.mustprogress"}
!13 = distinct !{!13, !12}
