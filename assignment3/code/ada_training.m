cnn1 = load('cnn-1y-d.mat');
cnn2 = load('cnn-1y-d.mat');
mlp = load('mlp.mat');
d = load('mnist.mat');

X4D = load('X4D.mat');
X = X4D.X4D;
Y = categorical(d.trainY);

alphas = [];
selected_wc = [];
wc = [cnn1.m, cnn2.m, mlp.m];
wc_results = [];
wc_cmp = [];

for i = 1:size(wc, 2)
    r = classify(wc(i), X)';
    wc_results = [wc_results; r];
    cmp = zeros(size(r));
    for x = 1:size(cmp, 2)
        cmp(x) = r(x) ~= Y(x);
    end
    wc_cmp = [wc_cmp; cmp];
end

weighting = ones([1 size(Y, 2)])/size(Y, 2);

for i = 1:size(wc, 2) % iterations
    es = {};
    for wci = 1:size(wc, 2) % weak classifiers
        e = sum(weighting .* wc_cmp(wci, :));
        es{wci} = e;
    end
    
    min_e = 1;
    min_ei = 0;
        
    for esi = 1:size(es, 2)
        if es{esi} < min_e
            min_e = es{esi};
            min_ei = esi;
        end
    end
    
    selected_wc = [selected_wc, wc(min_ei)];
    
    alpha = 1/2 * log((1-min_e)/min_e);
    alphas = [alphas, alpha];
    
    sigma = 0;
    
    for wi = 1:size(weighting, 2)
        weighting(wi) = weighting(wi) * exp(-alpha * -sign(wc_cmp(1,wi)*2-1));
        sigma = sigma + weighting(wi);
    end
    
    weighting = weighting * 1/sigma;
end

save 'ada' alphas selected_wc
