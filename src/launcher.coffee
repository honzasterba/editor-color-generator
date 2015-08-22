module.exports = generator

g = generator(0, 0.7, 0.2, 0.5)
console.log g.primary
console.log g.secondary
for c in g.accents 5
  console.log c
#console.log g.base(0), g.base(0.3), g.base(0.6), g.base(1) 
