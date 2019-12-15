function [psnr_intra,bitrates] = intra_eval(frames,video_height,video_width,recon_frames,coeff,steps,block_size,fps)
    
    block = 16;
    hist_intra = zeros(length(steps),length(frames),block_size,block_size,video_height/block,video_width/block,4);
    
    for i = 1 : length(steps)
        for j = 1 : length(frames)
            psnr_intra(i,j) = my_mse(recon_frames{i,j},frames{j});
            %psnr_intra = my_psnr(psnr_intra);
            for index1 = 1 : video_height/block
                for index2 = 1 : video_width/block
                    hist_intra(i,j,:,:,index1,index2,1) = coeff{i,j}{index1,index2}(1:8,1:8);
                    hist_intra(i,j,:,:,index1,index2,2) = coeff{i,j}{index1,index2}(1:8,9:16);
                    hist_intra(i,j,:,:,index1,index2,3) = coeff{i,j}{index1,index2}(9:16,1:8);
                    hist_intra(i,j,:,:,index1,index2,4) = coeff{i,j}{index1,index2}(9:16,9:16);
                end
            end
        end
    end
    
    bitrates = zeros(length(steps),length(frames),block_size,block_size);
    
    for i = 1 : length(steps)
        for j = 1 : length(frames)
            for blcok_index1 = 1 : block_size
                for block_index2 = 1 : block_size
                    prob = reshape(hist_intra(i,j,blcok_index1,block_index2,:,:,:),1,(video_height/block)*(video_width/block)*4);
                    prob = hist(prob,min(prob):steps(i):max(prob));
                    prob = prob./sum(prob);
                    bitrates(i,j,blcok_index1,block_index2) = -sum(prob.*log2(prob+eps));
                end
            end
        end
    end
    
    psnr_intra = sum(psnr_intra,2) / length(frames);
    psnr_intra = my_psnr(psnr_intra);

    bitrates = sum(bitrates,4);
    bitrates = sum(bitrates,3);
    %bitrates = bitrates./256;
    bitrates = bitrates*9*11*4;
    bitrates = sum(bitrates,2)/length(frames);
    bitrates = bitrates*fps/1000;

end